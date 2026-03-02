//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public final class LocalFuelingCalculator: FuelingCalculatorDataSource {
    // MARK: - Constants

    private enum Constants {
        /// Each time-slot is 5 minutes (the atomic unit for scheduling).
        static let slotDuration: TimeInterval = 300.0

        /// Caffeine pharmacokinetics.
        static let caffeineHalfLifeSeconds: TimeInterval = 5 * 3600 // 5 h
        static let caffeineLeadTimeSeconds: TimeInterval = 3 * 3600 // ideal: ~3 h before finish

        /// Simulated-annealing hyper-parameters
        static let saIterations = 30000
        static let saInitialTemperature = 500.0
        static let saCoolingRate = 0.99975

        /// Sliding-window size for the smoothness objective (12 slots = 1 hour).
        static let smoothnessWindowSlots = 12

        /// Objective weights
        static let wWindowSmoothness: Double = 1.0
        static let wCaffeineTiming: Double = 30.0

        /// How strongly to penalise early-hour surpluses over late-hour ones.
        /// 0.0 = no bias; higher values push more carbs toward the end.
        static let wEarlyLoadBias: Double = 0.15
    }

    // MARK: - Public initializer

    public init() {}

    // MARK: - FuelingCalculatorDataSource

    public func calculateFueling(from input: FuelingInput) -> TriGuideDomain.FuelingResult {
        let totalDuration = input.duration
        let startBuffer = input.startBuffer
        let endBuffer = input.endBuffer
        let minCarbSpacing = input.minCarbSpacing
        let minCafSpacing = input.minCaffeineSpacing

        // Expand selections into individual items
        var drinkItems: [CarbItem] = []
        var instantItems: [CarbItem] = []
        for sel in input.carbItemSelection where sel.item.gramsOfCarbs > 0 {
            let count = max(0, Int(sel.quantity))
            for _ in 0 ..< count {
                if sel.item.type == .drink {
                    drinkItems.append(sel.item)
                } else {
                    instantItems.append(sel.item)
                }
            }
        }

        let slotCount = max(1, Int(ceil(totalDuration / Constants.slotDuration)))
        let allItems = drinkItems + instantItems
        let totalCarbs = allItems.reduce(0.0) { $0 + $1.gramsOfCarbs }

        // The effective fueling window is [startBuffer, totalDuration].
        // Compute the target per slot based on that window so the first
        // slots (before startBuffer) having 0 carbs is expected.
        let fuelingSlotCount = max(1, slotCount - Int(ceil(startBuffer / Constants.slotDuration)))
        let targetCarbsPerSlot = totalCarbs / Double(fuelingSlotCount)

        // Place drinks as sequential intervals [startBuffer, totalDuration]
        let orderedDrinks = orderDrinksForSmoothness(drinkItems)
        let drinkEvents = placeDrinks(
            drinkItems: orderedDrinks,
            startTime: startBuffer,
            totalDuration: totalDuration
        )

        // Carb baseline from drinks per slot
        var drinkCarbsPerSlot = Array(repeating: 0.0, count: slotCount)
        for event in drinkEvents {
            if case let .interval(start, end) = event.consumption {
                distributeIntervalToSlots(
                    start: start, end: end,
                    carbs: event.carbItem.gramsOfCarbs,
                    into: &drinkCarbsPerSlot,
                    slotCount: slotCount,
                    totalDuration: totalDuration
                )
            }
        }

        // Valid placement range for instants
        let minSlot = max(0, Int(ceil(startBuffer / Constants.slotDuration)))
        let maxSlot = max(minSlot,
                          min(slotCount - 1,
                              Int(floor((totalDuration - endBuffer) / Constants.slotDuration))))
        let spacingSlots = max(1, Int(ceil(minCarbSpacing / Constants.slotDuration)))
        let cafSpacingSlots = max(1, Int(ceil(minCafSpacing / Constants.slotDuration)))

        // Caffeine timing target
        let idealCafSlot = idealCaffeineSlot(
            duration: totalDuration,
            startBuffer: startBuffer,
            endBuffer: endBuffer,
            slotCount: slotCount,
            hasConsumedCaffeineBefore: input.hasConsumedCaffeineBefore
        )

        // Order instants: caffeinated first, then by size desc
        let caffeinatedInstants = instantItems
            .filter { ($0.caffeine ?? 0) > 0 }
            .sorted { $0.gramsOfCarbs > $1.gramsOfCarbs }
        let nonCaffeinatedInstants = instantItems
            .filter { ($0.caffeine ?? 0) <= 0 }
            .sorted { $0.gramsOfCarbs > $1.gramsOfCarbs }
        let orderedInstants = caffeinatedInstants + nonCaffeinatedInstants
        let cafCount = caffeinatedInstants.count

        // Early exit when there are no instants
        guard !orderedInstants.isEmpty else {
            return buildResult(
                drinkEvents: drinkEvents,
                instantPlacements: [],
                instants: [],
                input: input
            )
        }

        // Greedy initial placement
        var placements = greedyPlacement(
            instants: orderedInstants,
            baseCarbsPerSlot: drinkCarbsPerSlot,
            targetPerSlot: targetCarbsPerSlot,
            minSlot: minSlot,
            maxSlot: maxSlot,
            spacingSlots: spacingSlots,
            cafSpacingSlots: cafSpacingSlots,
            idealCafSlot: idealCafSlot,
            cafCount: cafCount,
            slotCount: slotCount
        )

        // Simulated-annealing refinement
        placements = annealPlacements(
            placements: placements,
            instants: orderedInstants,
            baseCarbsPerSlot: drinkCarbsPerSlot,
            targetPerSlot: targetCarbsPerSlot,
            minSlot: minSlot,
            maxSlot: maxSlot,
            spacingSlots: spacingSlots,
            cafSpacingSlots: cafSpacingSlots,
            idealCafSlot: idealCafSlot,
            cafCount: cafCount,
            slotCount: slotCount
        )

        // Build output
        return buildResult(
            drinkEvents: drinkEvents,
            instantPlacements: placements,
            instants: orderedInstants,
            input: input
        )
    }

    // MARK: - Compute breakdown per interval

    public static func computeBreakDown(
        minutes: Double = 60,
        totalDuration: TimeInterval,
        events: [FuelingEvent]
    ) -> [IntervalFueling] {
        let durationInSeconds = minutes * 60.0
        let intervalsCount = max(1, Int(ceil(totalDuration / durationInSeconds)))
        var carbsPerInterval = Array(repeating: 0.0, count: intervalsCount)
        var caffeinePerInterval = Array(repeating: 0.0, count: intervalsCount)
        var waterVolumePerInterval = Array(repeating: 0.0, count: intervalsCount)
        let intervalSlots: [(start: TimeInterval, end: TimeInterval)] = (0 ..< intervalsCount).map { i in
            let s = Double(i) * durationInSeconds
            let e = min(totalDuration, Double(i + 1) * durationInSeconds)
            return (s, e)
        }

        for ev in events {
            switch ev.consumption {
            case let .instant(t):
                if let idx = intervalSlots.firstIndex(where: { t >= $0.start && t < $0.end }) {
                    carbsPerInterval[idx] += ev.carbItem.gramsOfCarbs
                    if let caf = ev.carbItem.caffeine {
                        caffeinePerInterval[idx] += caf
                    }
                    if let waterVolume = ev.carbItem.waterVolumeML {
                        waterVolumePerInterval[idx] += waterVolume
                    }
                }
            case let .interval(s, e):
                let len = max(1e-9, e - s)
                for (i, slot) in intervalSlots.enumerated() {
                    let overlap = max(0.0, min(slot.end, e) - max(slot.start, s))
                    if overlap > 0 {
                        let frac = overlap / len
                        carbsPerInterval[i] += ev.carbItem.gramsOfCarbs * frac
                        if let caf = ev.carbItem.caffeine {
                            caffeinePerInterval[i] += caf * frac
                        }
                        if let waterVolume = ev.carbItem.waterVolumeML {
                            waterVolumePerInterval[i] += waterVolume * frac
                        }
                    }
                }
            }
        }

        return (0 ..< intervalsCount).map { i in
            IntervalFueling(
                duration: durationInSeconds,
                hourIndex: i,
                carbGrams: carbsPerInterval[i],
                caffeine: caffeinePerInterval[i],
                waterVolumeML: waterVolumePerInterval[i]
            )
        }
    }
}

// MARK: - Private helpers

private extension LocalFuelingCalculator {
    // MARK: Build final result

    func buildResult(
        drinkEvents: [FuelingEvent],
        instantPlacements: [Int],
        instants: [CarbItem],
        input: FuelingInput
    ) -> FuelingResult {
        var allEvents = drinkEvents
        for (i, slot) in instantPlacements.enumerated() {
            let rawTime = Double(slot) * Constants.slotDuration + Constants.slotDuration / 2.0
            let clamped = max(input.startBuffer,
                              min(input.duration - input.endBuffer, rawTime))
            let rounded = clamped.roundedToNearest(minutes: 5)
            allEvents.append(
                FuelingEvent(consumption: .instant(time: rounded),
                             carbItem: instants[i])
            )
        }
        let sorted = allEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let breakdown = Self.computeBreakDown(totalDuration: input.duration, events: allEvents)
        return FuelingResult(
            name: nil,
            timeLine: sorted,
            totalCarbsTarget: input.carbsTarget,
            duration: input.duration,
            selectedItems: input.carbItemSelection,
            hourlyBreakdown: breakdown
        )
    }

    // MARK: Drink ordering & placement

    /// Re-order drinks so that high-carb-rate and low-carb-rate intervals
    /// alternate, yielding a flatter carb curve across the whole race.
    func orderDrinksForSmoothness(_ drinks: [CarbItem]) -> [CarbItem] {
        guard drinks.count > 1 else { return drinks }

        // carb-rate ∝ gramsOfCarbs / waterVolumeML (concentration)
        let sorted = drinks.sorted {
            let vol0 = max(0.001, $0.waterVolumeML ?? $0.gramsOfCarbs)
            let vol1 = max(0.001, $1.waterVolumeML ?? $1.gramsOfCarbs)
            return ($0.gramsOfCarbs / vol0) < ($1.gramsOfCarbs / vol1)
        }

        // Interleave from the extremes: high, low, 2nd-high, 2nd-low
        var result: [CarbItem] = []
        var lo = 0, hi = sorted.count - 1
        var takeHigh = true
        while lo <= hi {
            result.append(takeHigh ? sorted[hi] : sorted[lo])
            if takeHigh { hi -= 1 } else { lo += 1 }
            takeHigh.toggle()
        }
        return result
    }

    /// Tile drinks as back-to-back intervals over `[startTime, totalDuration]`.
    /// Each drink's duration is proportional to its `waterVolumeML`
    /// (falls back to `gramsOfCarbs` when volume is nil).
    func placeDrinks(
        drinkItems: [CarbItem],
        startTime: TimeInterval,
        totalDuration: TimeInterval
    ) -> [FuelingEvent] {
        guard !drinkItems.isEmpty else { return [] }

        let availableDuration = max(0, totalDuration - startTime)
        let weights = drinkItems.map { max(0.001, $0.waterVolumeML ?? $0.gramsOfCarbs) }
        let totalWeight = weights.reduce(0.0, +)
        var cursor: TimeInterval = startTime
        var results: [FuelingEvent] = []

        for (i, item) in drinkItems.enumerated() {
            let segLen = availableDuration * (weights[i] / totalWeight)
            let start = cursor.roundedToNearest(minutes: 5)
            let end = min(totalDuration, cursor + segLen).roundedToNearest(minutes: 5)
            results.append(
                FuelingEvent(consumption: .interval(start: start, end: end),
                             carbItem: item)
            )
            cursor += segLen
        }

        // Make sure the last drink reaches the end of the race
        if let last = results.last,
           case let .interval(start, end) = last.consumption,
           end < totalDuration
        {
            let newEnd = totalDuration.roundedToNearest(minutes: 5)
            results[results.count - 1] =
                FuelingEvent(consumption: .interval(start: min(start, newEnd), end: newEnd),
                             carbItem: last.carbItem)
        }
        return results
    }

    // MARK: Slot-level helpers

    /// Distribute the carbs of a drink interval across 5-minute slots
    /// proportionally to each slot's overlap with the interval.
    func distributeIntervalToSlots(
        start: TimeInterval,
        end: TimeInterval,
        carbs: Double,
        into slotsCarbs: inout [Double],
        slotCount: Int,
        totalDuration: TimeInterval
    ) {
        let intervalLen = max(1e-9, end - start)
        for slot in 0 ..< slotCount {
            let slotStart = Double(slot) * Constants.slotDuration
            let slotEnd = min(totalDuration, slotStart + Constants.slotDuration)
            let overlap = max(0.0, min(slotEnd, end) - max(slotStart, start))
            if overlap > 0 {
                slotsCarbs[slot] += carbs * (overlap / intervalLen)
            }
        }
    }

    // MARK: Caffeine timing

    /// The ideal slot to place caffeine.
    ///
    /// Strategy based on caffeine's 5 h aprox half-life:
    /// • Short races (≤ half-life) **without** pre-race caffeine → midpoint.
    /// • Short races **with** pre-race caffeine → pushed to ~60-70 % mark
    ///   so the exogenous dose kicks in as the pre-race caffeine wanes.
    /// • Long races → around 3 h before the finish regardless, so the effect
    ///   is strongest during the hardest final stretch.
    func idealCaffeineSlot(
        duration: TimeInterval,
        startBuffer: TimeInterval,
        endBuffer: TimeInterval,
        slotCount: Int,
        hasConsumedCaffeineBefore: Bool
    ) -> Int {
        let maxValidSlot = max(0,
                               min(slotCount - 1,
                                   Int(floor((duration - endBuffer) / Constants.slotDuration))))
        let minValidSlot = max(0, Int(ceil(startBuffer / Constants.slotDuration)))

        let idealTime: TimeInterval
        if duration <= Constants.caffeineHalfLifeSeconds {
            // Short race: caffeine will last until the end anyway.
            if hasConsumedCaffeineBefore {
                // Pre-race dose is still active, delay in-race caffeine
                // to 65 % of the race so it refreshes the effect.
                idealTime = duration * 0.65
            } else {
                // No prior caffeine, place around the midpoint so the
                // peak effect covers the toughest middle-to-end portion.
                idealTime = duration * 0.50
            }
        } else {
            // Long race: target 3 h before finish.
            idealTime = max(startBuffer, duration - Constants.caffeineLeadTimeSeconds)
        }

        let raw = Int(round(idealTime / Constants.slotDuration))
        return max(minValidSlot, min(raw, maxValidSlot))
    }

    // MARK: Constraint checking

    /// Check that placing instant `index` at `slot` respects all hard
    /// spacing constraints relative to every other already-assigned instant.
    func satisfiesSpacing(
        index: Int,
        slot: Int,
        placements: [Int],
        instants: [CarbItem],
        spacingSlots: Int,
        cafSpacingSlots: Int
    ) -> Bool {
        let isCaf = (instants[index].caffeine ?? 0) > 0
        for (j, other) in placements.enumerated() where j != index {
            let dist = abs(slot - other)
            if dist < spacingSlots { return false }
            if isCaf, (instants[j].caffeine ?? 0) > 0, dist < cafSpacingSlots {
                return false
            }
        }
        return true
    }

    // MARK: Objective function

    /// Sliding-window smoothness + caffeine-timing penalty +
    /// early-load bias (prefer fewer carbs in the first hours).
    func objective(
        placements: [Int],
        instants: [CarbItem],
        baseCarbsPerSlot: [Double],
        targetPerSlot: Double,
        idealCafSlot: Int,
        slotCount: Int
    ) -> Double {
        // Build total carbs per slot
        var carbs = baseCarbsPerSlot
        for (i, slot) in placements.enumerated() {
            guard slot >= 0, slot < carbs.count else { continue }
            carbs[slot] += instants[i].gramsOfCarbs
        }

        // Sliding-window hourly smoothness with early-load bias
        let w = min(Constants.smoothnessWindowSlots, slotCount)
        let targetPerWindow = targetPerSlot * Double(w)
        let numWindows = max(1, slotCount - w + 1)
        let bias = Constants.wEarlyLoadBias

        // First window
        var windowSum = 0.0
        for j in 0 ..< w {
            windowSum += carbs[j]
        }
        var windowVariance = 0.0
        let d0 = windowSum - targetPerWindow
        // Weight: early windows (start=0) get weight > 1, later ones ≈ 1.
        // 1 + bias*(1 - t) where t ∈ [0,1] maps the window position.
        let w0 = 1.0 + bias * (1.0 - 0.0 / Double(max(1, numWindows - 1)))
        windowVariance += d0 * d0 * w0

        // Slide
        for start in 1 ..< numWindows {
            windowSum += carbs[start + w - 1] - carbs[start - 1]
            let d = windowSum - targetPerWindow
            let t = Double(start) / Double(max(1, numWindows - 1))
            let weight = 1.0 + bias * (1.0 - t)
            windowVariance += d * d * weight
        }
        windowVariance /= Double(numWindows)

        // Caffeine timing penalty (squared distance from ideal slot)
        var cafPenalty = 0.0
        for (i, slot) in placements.enumerated() {
            if (instants[i].caffeine ?? 0) > 0 {
                let d = Double(abs(slot - idealCafSlot))
                cafPenalty += d * d
            }
        }
        cafPenalty = Constants.wCaffeineTiming * cafPenalty / Double(max(1, slotCount))

        return Constants.wWindowSmoothness * windowVariance + cafPenalty
    }

    // MARK: Greedy initial placement

    func greedyPlacement(
        instants: [CarbItem],
        baseCarbsPerSlot: [Double],
        targetPerSlot: Double,
        minSlot: Int,
        maxSlot: Int,
        spacingSlots: Int,
        cafSpacingSlots: Int,
        idealCafSlot: Int,
        cafCount _: Int,
        slotCount: Int
    ) -> [Int] {
        var placements: [Int] = []

        for (i, _) in instants.enumerated() {
            var bestSlot = minSlot
            var bestScore = Double.greatestFiniteMagnitude
            var foundValid = false

            for slot in minSlot ... maxSlot {
                // Hard spacing check against previously placed items
                var trial = placements
                trial.append(slot)
                if !satisfiesSpacing(index: i, slot: slot,
                                     placements: trial,
                                     instants: instants,
                                     spacingSlots: spacingSlots,
                                     cafSpacingSlots: cafSpacingSlots)
                {
                    continue
                }

                // Evaluate the sliding-window objective with items placed so far
                let score = objective(
                    placements: trial,
                    instants: Array(instants.prefix(i + 1)),
                    baseCarbsPerSlot: baseCarbsPerSlot,
                    targetPerSlot: targetPerSlot,
                    idealCafSlot: idealCafSlot,
                    slotCount: slotCount
                )

                if score < bestScore {
                    bestScore = score
                    bestSlot = slot
                    foundValid = true
                }
            }

            // Fallback: if no valid slot found (too many items), pick the
            // slot with the lowest windowed carbs ignoring spacing constraints.
            if !foundValid {
                bestSlot = minSlot
                var minCarbs = Double.greatestFiniteMagnitude
                for slot in minSlot ... maxSlot {
                    if baseCarbsPerSlot[slot] < minCarbs {
                        minCarbs = baseCarbsPerSlot[slot]
                        bestSlot = slot
                    }
                }
            }

            placements.append(bestSlot)
        }
        return placements
    }

    // MARK: Simulated-annealing refinement

    func annealPlacements(
        placements: [Int],
        instants: [CarbItem],
        baseCarbsPerSlot: [Double],
        targetPerSlot: Double,
        minSlot: Int,
        maxSlot: Int,
        spacingSlots: Int,
        cafSpacingSlots: Int,
        idealCafSlot: Int,
        cafCount _: Int,
        slotCount: Int
    ) -> [Int] {
        guard instants.count > 1 else { return placements }

        var current = placements
        var currentCost = objective(
            placements: current, instants: instants,
            baseCarbsPerSlot: baseCarbsPerSlot,
            targetPerSlot: targetPerSlot,
            idealCafSlot: idealCafSlot, slotCount: slotCount
        )
        var best = current
        var bestCost = currentCost
        var temperature = Constants.saInitialTemperature

        for _ in 0 ..< Constants.saIterations {
            let idx = Int.random(in: 0 ..< instants.count)
            let newSlot = Int.random(in: minSlot ... maxSlot)
            guard newSlot != current[idx] else { continue }

            // Try the move
            var candidate = current
            candidate[idx] = newSlot

            // Check hard constraints for the moved item
            if !satisfiesSpacing(index: idx, slot: newSlot,
                                 placements: candidate,
                                 instants: instants,
                                 spacingSlots: spacingSlots,
                                 cafSpacingSlots: cafSpacingSlots)
            {
                continue
            }

            let candidateCost = objective(
                placements: candidate, instants: instants,
                baseCarbsPerSlot: baseCarbsPerSlot,
                targetPerSlot: targetPerSlot,
                idealCafSlot: idealCafSlot, slotCount: slotCount
            )

            let delta = candidateCost - currentCost
            if delta < 0 || Double.random(in: 0 ... 1) < exp(-delta / max(temperature, 1e-12)) {
                current = candidate
                currentCost = candidateCost
                if currentCost < bestCost {
                    best = current
                    bestCost = currentCost
                }
            }

            temperature *= Constants.saCoolingRate
        }

        return best
    }
}
