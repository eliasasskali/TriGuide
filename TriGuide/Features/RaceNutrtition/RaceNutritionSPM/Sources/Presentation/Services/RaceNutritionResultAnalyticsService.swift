//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

// MARK: - RaceNutritionResultAnalyticsData

public struct RaceNutritionResultAnalyticsData {
    public let calculationId: String?
    public let wasEdited: Bool
    public let durationSeconds: Double
    public let totalCarbsTarget: Double
    public let totalSelectedCarbs: Double
    public let carbTargetPerHour: Double
    public let actualCarbsPerHour: Double
    public let carbDeficitRatio: Double
    public let totalTimelineEvents: Int
    public let totalCaffeineMg: Double
    public let totalWaterVolumeML: Double
    public let firstCaffeineTimeSeconds: Double?
    public let drinkCoverageRatio: Double
    public let carbDistributionVariance: Double

    public init(from result: FuelingResult, calculationId: String? = nil, wasEdited: Bool = false) {
        self.calculationId = calculationId
        self.wasEdited = wasEdited
        durationSeconds = result.duration
        totalCarbsTarget = result.totalCarbsTarget
        totalSelectedCarbs = result.totalSelectedCarbs
        carbTargetPerHour = result.carbTargetPerHour
        actualCarbsPerHour = result.actualCarbsPerHour
        carbDeficitRatio = result.totalCarbsTarget > 0
            ? result.totalSelectedCarbs / result.totalCarbsTarget
            : 0
        totalTimelineEvents = result.timeLine.count

        totalCaffeineMg = result.selectedItems.reduce(0) {
            $0 + ($1.item.caffeine ?? 0) * $1.quantity
        }
        totalWaterVolumeML = result.selectedItems.reduce(0) {
            $0 + ($1.item.waterVolumeML ?? 0) * $1.quantity
        }

        let sortedTimeline = result.timeLine.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        firstCaffeineTimeSeconds = sortedTimeline
            .first { ($0.carbItem.caffeine ?? 0) > 0 }
            .map { $0.consumptionTimeOrZero }

        let totalDrinkInterval = result.timeLine.reduce(0.0) { total, event in
            guard case let .interval(start, end) = event.consumption else { return total }
            return total + (end - start)
        }
        drinkCoverageRatio = result.duration > 0 ? totalDrinkInterval / result.duration : 0

        let hourlyCarbValues = result.hourlyBreakdown.map { $0.carbGrams }
        let mean = hourlyCarbValues.isEmpty ? 0 : hourlyCarbValues.reduce(0, +) / Double(hourlyCarbValues.count)
        let sumSquaredDiffs = hourlyCarbValues.reduce(0) { $0 + ($1 - mean) * ($1 - mean) }
        carbDistributionVariance = hourlyCarbValues.isEmpty ? 0 : sumSquaredDiffs / Double(hourlyCarbValues.count)
    }
}

// MARK: - RaceNutritionResultAnalyticsService

public protocol RaceNutritionResultAnalyticsService {
    func trackScreenView()
    func trackFuelingResultGenerated(data: RaceNutritionResultAnalyticsData)
    func trackSavePlanClick()
    func trackPlanSaved(planName: String, data: RaceNutritionResultAnalyticsData)
    func trackEditPlanClick()
    func trackToggleSelectedItems(expanded: Bool)
}
