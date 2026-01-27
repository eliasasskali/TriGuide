//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public final class LocalFuelingCalculator: FuelingCalculatorDataSource {
    // MARK: - Constants

    private enum Constants {
        static let batchSeconds: TimeInterval = 300.0 // 5 minutes
        static let digestionWindowScale: Double = 1.5 // scales gram-proportion -> window length in batches
        static let wVariance: Double = 1.0
        static let wCafPeak: Double = 200.0
        static let wAdjSame: Double = 50.0
        static let occupiedBatchPenalty: Double = 1e6
        static let minCaffeineSpacingMin: Int = 40 // minutes (default from your earlier algorithm)
    }

    // MARK: - Public initializer

    public init() {}

    // MARK: - FuelingCalculatorDataSource

    public func calculateFueling(from input: FuelingInput) -> TriGuideDomain.FuelingResult {
        // high-level steps: expand selections -> batches -> place drinks -> place instants (caffeinated first) -> refinement -> build output

        let selections = input.carbItemSelection
        let totalDuration = input.duration
        let startBuffer = input.startBuffer

        // Expand selections into individual items (respecting quantity)
        var drinkItems: [CarbItem] = []
        var instantItems: [CarbItem] = []
        for sel in selections where sel.item.gramsOfCarbs > 0 {
            let count = max(0, Int(sel.quantity))
            for _ in 0 ..< count {
                if sel.item.type == .drink {
                    drinkItems.append(sel.item)
                } else {
                    instantItems.append(sel.item)
                }
            }
        }

        drinkItems = drinkItems.sorted(by: { $0.gramsOfCarbs < $1.gramsOfCarbs })

        // Basic totals
        let totalCarbs = (drinkItems + instantItems).reduce(0.0) { $0 + $1.gramsOfCarbs }
        let totalCaffeine = (drinkItems + instantItems).reduce(0.0) { $0 + ($1.caffeine ?? 0.0) }

        // Batches across entire duration
        let batchesCount = max(1, Int(ceil(totalDuration / Constants.batchSeconds)))
        let earliestInstantBatch = Int(ceil(startBuffer / Constants.batchSeconds))

        // Arrays representing current plan state
        var carbsPerBatch = Array(repeating: 0.0, count: batchesCount)
        var caffeinePerBatch = Array(repeating: 0.0, count: batchesCount)
        var occupiedInstantBatch = Array(repeating: false, count: batchesCount)

        // Helper for batch time
        func batchStartTime(_ b: Int) -> TimeInterval { Double(b) * Constants.batchSeconds }
        func batchCenterTime(_ b: Int) -> TimeInterval { batchStartTime(b) + Constants.batchSeconds / 2.0 }

        // Events container
        var events: [TriGuideDomain.FuelingEvent] = []

        // Place drinks as continuous intervals across totalDuration, start at time 0
        let drinkEvents = placeDrinks(drinkItems: drinkItems, totalDuration: totalDuration)
        for event in drinkEvents {
            if let (start, end) = intervalBounds(event) {
                events.append(event)
                // Distribute drink carbs/caffeine into batches by overlap
                distributeIntervalToBatches(
                    start: start,
                    end: end,
                    item: event.carbItem,
                    carbsPerBatch: &carbsPerBatch,
                    caffeinePerBatch: &caffeinePerBatch,
                    batchesCount: batchesCount,
                    totalDuration: totalDuration
                )
            }
        }

        let carbsAssignedFromDrinks = carbsPerBatch.reduce(0.0, +)
        let remainingCarbs = max(0.0, totalCarbs - carbsAssignedFromDrinks)

        // keep original overall target for objective
        let targetCarbsPerBatch = totalCarbs / Double(batchesCount)

        // but use a separate target for instants that reflects only the remaining carbs
        let remainingBatches = max(1, batchesCount - earliestInstantBatch)
        let targetCarbsPerBatchForInstants = remainingCarbs / Double(remainingBatches)

        // keep caffeine baseline per batch — useful for penalizing caffeine peaks
        let targetCafPerBatch = totalCaffeine / Double(batchesCount)

        // Place instants (split caffeinated first)
        let caffeinatedInstants = instantItems.filter {
            ($0.caffeine ?? 0.0) > 0.0
        }.sorted {
            $0.gramsOfCarbs > $1.gramsOfCarbs
        }
        let nonCaffeinatedInstants = instantItems.filter {
            ($0.caffeine ?? 0.0) <= 0.0
        }.sorted {
            $0.gramsOfCarbs > $1.gramsOfCarbs
        }

        // Track placements for spacing and repetition penalties
        var lastPlacementById: [String: Int] = [:]
        var caffeinatedPlacementIndices: [Int] = []
        let minCaffeineSpacingBatches = max(1, Int(ceil(Double(Constants.minCaffeineSpacingMin) / 5.0)))

        // Place caffeinated first
        for item in caffeinatedInstants {
            let chosenBatch = chooseBestBatchForInstant(
                item: item,
                earliestBatch: earliestInstantBatch,
                batchesCount: batchesCount,
                carbsPerBatch: carbsPerBatch,
                caffeinePerBatch: caffeinePerBatch,
                occupiedInstantBatch: occupiedInstantBatch,
                lastPlacementById: lastPlacementById,
                caffeinatedPlacementIndices: caffeinatedPlacementIndices,
                totalCarbs: totalCarbs,
                targetCarbsPerBatch: targetCarbsPerBatchForInstants,
                targetCafPerBatch: targetCafPerBatch,
                minCaffeineSpacingBatches: minCaffeineSpacingBatches
            )

            // Apply placement
            let window = digestionWindowFor(
                item: item,
                totalCarbs: max(1.0, totalCarbs),
                batchesCount: batchesCount
            )
            applyInstant(
                item: item,
                atBatch: chosenBatch,
                windowBatches: window,
                carbsPerBatch: &carbsPerBatch,
                caffeinePerBatch: &caffeinePerBatch,
                occupiedInstantBatch: &occupiedInstantBatch
            )

            // Record event
            let time = max(batchCenterTime(chosenBatch), startBuffer) // never before startBuffer
            let timeRounded = time.roundedToNearest(minutes: 5)
            events.append(TriGuideDomain.FuelingEvent(consumption: .instant(time: timeRounded), carbItem: item))
            lastPlacementById[item.id] = chosenBatch
            caffeinatedPlacementIndices.append(chosenBatch)
        }

        // Place non-caffeinated instants
        for item in nonCaffeinatedInstants {
            let chosenBatch = chooseBestBatchForInstant(
                item: item,
                earliestBatch: earliestInstantBatch,
                batchesCount: batchesCount,
                carbsPerBatch: carbsPerBatch,
                caffeinePerBatch: caffeinePerBatch,
                occupiedInstantBatch: occupiedInstantBatch,
                lastPlacementById: lastPlacementById,
                caffeinatedPlacementIndices: caffeinatedPlacementIndices,
                totalCarbs: totalCarbs,
                targetCarbsPerBatch: targetCarbsPerBatchForInstants,
                targetCafPerBatch: targetCafPerBatch,
                minCaffeineSpacingBatches: minCaffeineSpacingBatches
            )

            let window = digestionWindowFor(
                item: item,
                totalCarbs: max(1.0, totalCarbs),
                batchesCount: batchesCount
            )
            applyInstant(
                item: item,
                atBatch: chosenBatch,
                windowBatches: window,
                carbsPerBatch: &carbsPerBatch,
                caffeinePerBatch: &caffeinePerBatch,
                occupiedInstantBatch: &occupiedInstantBatch
            )

            let time = max(batchCenterTime(chosenBatch), startBuffer)
            let timeRounded = time.roundedToNearest(minutes: 5)
            events.append(TriGuideDomain.FuelingEvent(consumption: .instant(time: timeRounded), carbItem: item))
            lastPlacementById[item.id] = chosenBatch
        }

        // Local refinement: try small moves to reduce variance and caffeine peaks
        localRefinement(
            events: &events,
            carbsPerBatch: &carbsPerBatch,
            caffeinePerBatch: &caffeinePerBatch,
            occupiedInstantBatch: &occupiedInstantBatch,
            lastPlacementById: &lastPlacementById,
            totalCarbs: totalCarbs,
            targetCarbsPerBatch: targetCarbsPerBatch,
            batchesCount: batchesCount,
            earliestInstantBatch: earliestInstantBatch
        )

        // Sort timeline
        let sortedEvents = events.sorted { a, b in
            func startTime(of ev: TriGuideDomain.FuelingEvent) -> TimeInterval {
                switch ev.consumption {
                case let .instant(t): return t
                case let .interval(s, _): return s
                }
            }
            return startTime(of: a) < startTime(of: b)
        }

        // Build interval breakdown
        let intervalBreakdown = Self.computeBreakDown(
            totalDuration: totalDuration,
            events: events
        )

        return TriGuideDomain.FuelingResult(
            name: nil,
            timeLine: sortedEvents,
            totalCarbsTarget: input.carbsTarget,
            duration: totalDuration,
            selectedItems: input.carbItemSelection,
            hourlyBreakdown: intervalBreakdown
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
            let s = Double(i) * minutes * 60
            let e = min(totalDuration, Double(i + 1) * durationInSeconds)
            return (s, e)
        }

        // Aggregate events into hours
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
                for (i, slot) in intervalSlots.enumerated() {
                    let overlap = max(0.0, min(slot.end, e) - max(slot.start, s))
                    if overlap > 0 {
                        let frac = overlap / (e - s)
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

        var hourlyBreakdown: [TriGuideDomain.IntervalFueling] = []
        for i in 0 ..< intervalsCount {
            hourlyBreakdown.append(
                TriGuideDomain.IntervalFueling(
                    duration: durationInSeconds,
                    hourIndex: i,
                    carbGrams: carbsPerInterval[i],
                    caffeine: caffeinePerInterval[i],
                    waterVolumeML: waterVolumePerInterval[i]
                )
            )
        }

        return hourlyBreakdown
    }
}

// MARK: - Private methods

private extension LocalFuelingCalculator {
    // MARK: Interval Bounds Helper

    func intervalBounds(_ event: FuelingEvent) -> (start: TimeInterval, end: TimeInterval)? {
        switch event.consumption {
        case let .interval(s, e): return (s, e)
        case .instant: return nil
        }
    }

    // MARK: - Drinks placement

    func placeDrinks(
        drinkItems: [CarbItem],
        totalDuration: TimeInterval
    ) -> [TriGuideDomain.FuelingEvent] {
        guard !drinkItems.isEmpty else { return [] }
        // weight by waterVolumeML (fallback to gramsOfCarbs)
        let weights = drinkItems.map {
            max(0.0001, $0.gramsOfCarbs)
        }
        let totalWeight = weights.reduce(0.0, +)
        var cursor: TimeInterval = 0.0
        var results: [TriGuideDomain.FuelingEvent] = []
        for (i, item) in drinkItems.enumerated() {
            let segLen = totalDuration * (weights[i] / totalWeight)
            let start = cursor
            let end = min(totalDuration, cursor + segLen)
            let event = TriGuideDomain.FuelingEvent(consumption: .interval(start: start.roundedToNearest(minutes: 5), end: end.roundedToNearest(minutes: 5)), carbItem: item)
            results.append(event)
            cursor = end
        }
        // ensure last covers to end
        if let last = results.last,
           let (_, end) = intervalBounds(last),
           end < totalDuration,
           let start = intervalBounds(last)?.start
        {
            let newEnd = totalDuration.roundedToNearest(minutes: 5)
            let startClamped = min(start, newEnd)
            results[results.count - 1] = TriGuideDomain.FuelingEvent(consumption: .interval(start: startClamped, end: newEnd), carbItem: last.carbItem)
        }
        return results
    }

    // MARK: - Utility: distribute interval into batches

    func distributeIntervalToBatches(
        start: TimeInterval,
        end: TimeInterval,
        item: CarbItem,
        carbsPerBatch: inout [Double],
        caffeinePerBatch: inout [Double],
        batchesCount: Int,
        totalDuration: TimeInterval
    ) {
        let intervalLen = max(1e-6, end - start)
        for batch in 0 ..< batchesCount {
            let batchStart = Double(batch) * Constants.batchSeconds
            let batchEnd = min(totalDuration, batchStart + Constants.batchSeconds)
            let overlap = max(0.0, min(batchEnd, end) - max(batchStart, start))
            if overlap > 0 {
                let fraction = overlap / intervalLen
                carbsPerBatch[batch] += item.gramsOfCarbs * fraction
                if let caf = item.caffeine {
                    caffeinePerBatch[batch] += caf * fraction
                }
            }
        }
    }

    // MARK: - Digestion window based on grams proportion

    func digestionWindowFor(
        item: CarbItem,
        totalCarbs: Double,
        batchesCount: Int
    ) -> Int {
        guard totalCarbs > 0 else { return 1 }
        let proportion = item.gramsOfCarbs / totalCarbs
        let raw = proportion * Double(batchesCount) * Constants.digestionWindowScale
        let w = max(1, Int(round(raw)))
        return min(w, max(1, batchesCount))
    }

    // MARK: - Choose best batch for an instant (scoring)

    func chooseBestBatchForInstant(
        item: CarbItem,
        earliestBatch: Int,
        batchesCount: Int,
        carbsPerBatch: [Double],
        caffeinePerBatch: [Double],
        occupiedInstantBatch: [Bool],
        lastPlacementById: [String: Int],
        caffeinatedPlacementIndices: [Int],
        totalCarbs: Double,
        targetCarbsPerBatch: Double,
        targetCafPerBatch: Double,
        minCaffeineSpacingBatches: Int
    ) -> Int {
        let windowDefault = digestionWindowFor(
            item: item,
            totalCarbs: max(1.0, totalCarbs),
            batchesCount: batchesCount
        )

        var bestBatch = max(earliestBatch, 0)
        var bestScore = Double.greatestFiniteMagnitude

        for batchIndex in max(earliestBatch, 0) ..< batchesCount {
            // compute hypothetical arrays
            var carbsHyp = carbsPerBatch
            var cafHyp = caffeinePerBatch

            // window length truncated to available batches
            let window = min(windowDefault, batchesCount - batchIndex)
            let perBatchAdd = item.gramsOfCarbs / Double(window)
            let perBatchCafAdd = (item.caffeine ?? 0.0) / Double(window)

            for windowIndex in 0 ..< window {
                carbsHyp[batchIndex + windowIndex] += perBatchAdd
                cafHyp[batchIndex + windowIndex] += perBatchCafAdd
            }

            // variance term
            var varAfter = 0.0
            for i in 0 ..< batchesCount {
                let d = carbsHyp[i] - targetCarbsPerBatch
                varAfter += d * d
            }
            let termVariance = Constants.wVariance * varAfter

            // caffeine proximity penalty (only for caffeinated items)
            var termCafProx = 0.0
            if (item.caffeine ?? 0.0) > 0.0 {
                var minDist = Double.greatestFiniteMagnitude
                for placed in caffeinatedPlacementIndices {
                    minDist = min(minDist, Double(abs(placed - batchIndex)))
                }
                if minDist.isFinite {
                    if minDist < Double(minCaffeineSpacingBatches) {
                        let diff = Double(minCaffeineSpacingBatches) - minDist
                        termCafProx = Constants.wCafPeak * diff * diff
                    }
                }
                // also penalize caffeine peak in window center
                let windowCenterIndex = batchIndex + window / 2
                if windowCenterIndex < cafHyp.count {
                    let cafBaseline = targetCafPerBatch
                    let cafExcess = max(0.0, cafHyp[windowCenterIndex] - cafBaseline)
                    termCafProx += Constants.wCafPeak * cafExcess * cafExcess
                }
            }

            // same-item adjacency penalty
            var termAdj = 0.0
            if let last = lastPlacementById[item.id] {
                let dist = abs(last - batchIndex)
                termAdj = Constants.wAdjSame / Double(1 + dist)
            }

            // occupied instant penalty
            let occPenalty = occupiedInstantBatch[batchIndex] ? Constants.occupiedBatchPenalty : 0.0

            let score = termVariance + termCafProx + termAdj + occPenalty

            if score < bestScore {
                bestScore = score
                bestBatch = batchIndex
            }
        }

        return bestBatch
    }

    // MARK: - Apply instant (commit)

    func applyInstant(
        item: CarbItem,
        atBatch batch: Int,
        windowBatches: Int,
        carbsPerBatch: inout [Double],
        caffeinePerBatch: inout [Double],
        occupiedInstantBatch: inout [Bool]
    ) {
        let win = min(windowBatches, carbsPerBatch.count - batch)
        guard win > 0 else {
            return
        }
        let perBatchCarb = item.gramsOfCarbs / Double(win)
        let perBatchCaf = (item.caffeine ?? 0.0) / Double(win)
        for k in 0 ..< win {
            carbsPerBatch[batch + k] += perBatchCarb
            caffeinePerBatch[batch + k] += perBatchCaf
        }
        occupiedInstantBatch[batch] = true
    }

    // MARK: - Local refinement (simple hill-climb moves)

    private func localRefinement(
        events: inout [TriGuideDomain.FuelingEvent],
        carbsPerBatch: inout [Double],
        caffeinePerBatch: inout [Double],
        occupiedInstantBatch: inout [Bool],
        lastPlacementById: inout [String: Int],
        totalCarbs: Double,
        targetCarbsPerBatch: Double,
        batchesCount: Int,
        earliestInstantBatch: Int
    ) {
        // reconstruct instant placements from events (only instants)
        struct InstRec {
            var item: CarbItem
            var batch: Int
        }
        var insts: [InstRec] = []
        for event in events {
            switch event.consumption {
            case let .instant(time):
                let batch = Int(floor(time / Constants.batchSeconds))
                insts.append(InstRec(item: event.carbItem, batch: max(batch, earliestInstantBatch)))
            default:
                break
            }
        }

        // nothing to do
        if insts.isEmpty { return }

        // try moving each instant within +/- 2 batches
        for i in 0 ..< insts.count {
            let rec = insts[i]
            let currentBatch = rec.batch
            let window = digestionWindowFor(item: rec.item, totalCarbs: max(1.0, totalCarbs), batchesCount: batchesCount)
            var bestBatch = currentBatch
            var bestScore = globalObjective(carbsPerBatch: carbsPerBatch, target: targetCarbsPerBatch)

            // remove current contribution (this also clears occupiedInstantBatch[currentBatch])
            removeInstantContribution(
                item: rec.item,
                atBatch: currentBatch,
                windowBatches: window,
                carbsPerBatch: &carbsPerBatch,
                caffeinePerBatch: &caffeinePerBatch,
                occupiedInstantBatch: &occupiedInstantBatch
            )

            // search neighborhood +/- 2 batches (bounded)
            let low = max(earliestInstantBatch, currentBatch - 2)
            let high = min(batchesCount - 1, currentBatch + 2)
            for candidate in low ... high {
                // apply tentatively at candidate
                applyInstant(
                    item: rec.item,
                    atBatch: candidate,
                    windowBatches: window,
                    carbsPerBatch: &carbsPerBatch,
                    caffeinePerBatch: &caffeinePerBatch,
                    occupiedInstantBatch: &occupiedInstantBatch
                )

                let score = globalObjective(
                    carbsPerBatch: carbsPerBatch,
                    target: targetCarbsPerBatch
                )

                // revert the tentative placement
                removeInstantContribution(
                    item: rec.item,
                    atBatch: candidate,
                    windowBatches: window,
                    carbsPerBatch: &carbsPerBatch,
                    caffeinePerBatch: &caffeinePerBatch,
                    occupiedInstantBatch: &occupiedInstantBatch
                )

                if score < bestScore {
                    bestScore = score
                    bestBatch = candidate
                }
            }

            // commit best placement
            applyInstant(
                item: rec.item,
                atBatch: bestBatch,
                windowBatches: window,
                carbsPerBatch: &carbsPerBatch,
                caffeinePerBatch: &caffeinePerBatch,
                occupiedInstantBatch: &occupiedInstantBatch
            )

            // persist the chosen batch into insts so we can rebuild events later
            insts[i].batch = bestBatch

            // update last placement map (use stable key)
            lastPlacementById[rec.item.id] = bestBatch
        }

        // Rebuild events: remove old instant events and re-add new ones from insts (preserve intervals)
        events.removeAll { ev in
            if case .instant = ev.consumption { return true }
            return false
        }

        // Append instants based on final `insts` placements
        for rec in insts {
            let time = Double(rec.batch) * Constants.batchSeconds + Constants.batchSeconds / 2.0
            events.append(TriGuideDomain.FuelingEvent(consumption: .instant(time: time.roundedToNearest(minutes: 5)), carbItem: rec.item))
        }
    }

    func removeInstantContribution(
        item: CarbItem,
        atBatch b: Int,
        windowBatches: Int,
        carbsPerBatch: inout [Double],
        caffeinePerBatch: inout [Double],
        occupiedInstantBatch: inout [Bool]
    ) {
        let win = min(windowBatches, carbsPerBatch.count - b)
        guard win > 0 else { return }
        let perBatchCarb = item.gramsOfCarbs / Double(win)
        let perBatchCaf = (item.caffeine ?? 0.0) / Double(win)
        for k in 0 ..< win {
            carbsPerBatch[b + k] = max(0.0, carbsPerBatch[b + k] - perBatchCarb)
            caffeinePerBatch[b + k] = max(0.0, caffeinePerBatch[b + k] - perBatchCaf)
        }
        occupiedInstantBatch[b] = false
    }

    func globalObjective(carbsPerBatch: [Double], target: Double) -> Double {
        var v = 0.0
        for c in carbsPerBatch {
            let d = c - target
            v += d * d
        }
        return v
    }
}
