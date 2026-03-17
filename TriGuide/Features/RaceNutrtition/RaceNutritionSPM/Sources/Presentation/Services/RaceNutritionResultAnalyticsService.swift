//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

// MARK: - RaceNutritionResultAnalyticsData

public struct RaceNutritionResultAnalyticsData {
    public let durationSeconds: Double
    public let totalCarbsTarget: Double
    public let totalSelectedCarbs: Double
    public let carbTargetPerHour: Double
    public let actualCarbsPerHour: Double
    public let totalTimelineEvents: Int
    public let totalSelectedItems: Int
    public let remoteCarbItemIds: [String]
    public let userCarbItemNames: [String]
    public let totalCaffeineMg: Double
    public let totalWaterVolumeML: Double

    public init(from result: FuelingResult) {
        durationSeconds = result.duration
        totalCarbsTarget = result.totalCarbsTarget
        totalSelectedCarbs = result.totalSelectedCarbs
        carbTargetPerHour = result.carbTargetPerHour
        actualCarbsPerHour = result.actualCarbsPerHour
        totalTimelineEvents = result.timeLine.count
        totalSelectedItems = result.selectedItems.count
        remoteCarbItemIds = result.selectedItems
            .filter { !$0.item.isCustom }
            .map { $0.item.id }
        userCarbItemNames = result.selectedItems
            .filter { $0.item.isCustom }
            .map { $0.item.name }
        totalCaffeineMg = result.selectedItems.reduce(0) {
            $0 + ($1.item.caffeine ?? 0) * $1.quantity
        }
        totalWaterVolumeML = result.selectedItems.reduce(0) {
            $0 + ($1.item.waterVolumeML ?? 0) * $1.quantity
        }
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
