//
// TriGuide 2026
//

import Foundation
@testable import RaceNutritionSPM
import Testing
import TriGuideDomain

@Suite
struct LocalFuelingCalculatorTests {
    private let sut = LocalFuelingCalculator()
}

// MARK: - Hourly carb-smoothness tests

extension LocalFuelingCalculatorTests {
    /// 4 h race, 85 g/h target, mixed gels – expect every hour within ±30 g of the mean.
    @Test("4h mixed gels: hourly carbs variance stays within ±30g of mean")
    func fourHourMixedGels_hourlyVariance_isSmall() {
        let gelA = CarbItem(id: "gelA", name: "Gel 40g", gramsOfCarbs: 40, type: .gel)
        let gelB = CarbItem(id: "gelB", name: "Gel 25g", gramsOfCarbs: 25, type: .gel)
        let drink = CarbItem(id: "drink1", name: "Bottle 750ml", gramsOfCarbs: 90, waterVolumeML: 750, type: .drink)

        let selection: [CarbItemSelection] = [
            CarbItemSelection(item: gelA, quantity: 4),
            CarbItemSelection(item: gelB, quantity: 4),
            CarbItemSelection(item: drink, quantity: 2),
        ]

        let input = FuelingInput(
            carbItemSelection: selection,
            carbsTarget: 340,
            duration: 4 * 3600,
            sport: .bike
        )

        let result = sut.calculateFueling(from: input)
        assertHourlySmoothnessWithinTolerance(result: result, toleranceGrams: 30)
    }

    /// 2 h race, only gels – short race should still spread carbs evenly.
    @Test("2h gels only: hourly carbs variance stays within ±25g of mean")
    func twoHourGelsOnly_hourlyVariance_isSmall() {
        let gel = CarbItem(id: "gel", name: "Gel 30g", gramsOfCarbs: 30, type: .gel)

        let selection: [CarbItemSelection] = [
            CarbItemSelection(item: gel, quantity: 6),
        ]

        let input = FuelingInput(
            carbItemSelection: selection,
            carbsTarget: 180,
            duration: 2 * 3600,
            sport: .run
        )

        let result = sut.calculateFueling(from: input)
        assertHourlySmoothnessWithinTolerance(result: result, toleranceGrams: 25)
    }

    /// 6 h race, mixed drinks and gels with caffeine – long race smoothness.
    @Test("6h mixed race: hourly carbs variance stays within ±35g of mean")
    func sixHourMixedRace_hourlyVariance_isSmall() {
        let gel = CarbItem(id: "gel", name: "Gel 40g", gramsOfCarbs: 40, type: .gel)
        let cafGel = CarbItem(id: "cafGel", name: "Caf Gel 30g", gramsOfCarbs: 30, caffeine: 50, type: .gel)
        let drink = CarbItem(id: "drink", name: "Bottle 500ml", gramsOfCarbs: 60, waterVolumeML: 500, type: .drink)

        let selection: [CarbItemSelection] = [
            CarbItemSelection(item: gel, quantity: 6),
            CarbItemSelection(item: cafGel, quantity: 2),
            CarbItemSelection(item: drink, quantity: 3),
        ]

        let input = FuelingInput(
            carbItemSelection: selection,
            carbsTarget: 480,
            duration: 6 * 3600,
            sport: .triathlon
        )

        let result = sut.calculateFueling(from: input)
        assertHourlySmoothnessWithinTolerance(result: result, toleranceGrams: 35)
    }

    /// 4 h race, single drink + many gels – drink provides a steady baseline,
    /// gels should fill gaps rather than pile up.
    @Test("4h single drink + gels: hourly carbs variance stays within ±30g of mean")
    func fourHourSingleDrinkPlusGels_hourlyVariance_isSmall() {
        let gel = CarbItem(id: "gel", name: "Gel 25g", gramsOfCarbs: 25, type: .gel)
        let drink = CarbItem(id: "drink", name: "Big Bottle", gramsOfCarbs: 120, waterVolumeML: 1000, type: .drink)

        let selection: [CarbItemSelection] = [
            CarbItemSelection(item: gel, quantity: 8),
            CarbItemSelection(item: drink, quantity: 1),
        ]

        let input = FuelingInput(
            carbItemSelection: selection,
            carbsTarget: 320,
            duration: 4 * 3600,
            sport: .bike
        )

        let result = sut.calculateFueling(from: input)
        assertHourlySmoothnessWithinTolerance(result: result, toleranceGrams: 30)
    }

    /// 3 h race, identical gels only – the simplest case; should be nearly perfect.
    @Test("3h identical gels: hourly carbs variance stays within ±15g of mean")
    func threeHourIdenticalGels_hourlyVariance_isSmall() {
        let gel = CarbItem(id: "gel", name: "Gel 30g", gramsOfCarbs: 30, type: .gel)

        let selection: [CarbItemSelection] = [
            CarbItemSelection(item: gel, quantity: 9),
        ]

        let input = FuelingInput(
            carbItemSelection: selection,
            carbsTarget: 270,
            duration: 3 * 3600,
            sport: .run
        )

        let result = sut.calculateFueling(from: input)
        assertHourlySmoothnessWithinTolerance(result: result, toleranceGrams: 15)
    }
}

// MARK: - Helpers

private extension LocalFuelingCalculatorTests {
    /// Asserts that no hourly bucket deviates from the mean by more than `toleranceGrams`.
    func assertHourlySmoothnessWithinTolerance(
        result: FuelingResult,
        toleranceGrams: Double,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let hourly = result.hourlyBreakdown
        guard !hourly.isEmpty else {
            Issue.record("Hourly breakdown is empty", sourceLocation: sourceLocation)
            return
        }

        let carbValues = hourly.map(\.carbGrams)
        let mean = carbValues.reduce(0, +) / Double(carbValues.count)

        for (index, value) in carbValues.enumerated() {
            let deviation = abs(value - mean)
            #expect(
                deviation <= toleranceGrams,
                "Hour \(index): \(String(format: "%.1f", value))g deviates \(String(format: "%.1f", deviation))g from mean \(String(format: "%.1f", mean))g (tolerance: \(String(format: "%.0f", toleranceGrams))g)",
                sourceLocation: sourceLocation
            )
        }
    }
}
