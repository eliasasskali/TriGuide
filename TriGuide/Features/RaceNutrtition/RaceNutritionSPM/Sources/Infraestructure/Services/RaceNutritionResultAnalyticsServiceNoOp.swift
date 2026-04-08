//
// TriGuide 2026
//

import Foundation

/// A no-op implementation of `RaceNutritionResultAnalyticsService` that does nothing when its methods are called.
public struct RaceNutritionResultAnalyticsServiceNoOp: RaceNutritionResultAnalyticsService {
    public init() {}
    public func trackScreenView() {}
    public func trackFuelingResultGenerated(data _: RaceNutritionResultAnalyticsData) {}
    public func trackSavePlanClick() {}
    public func trackPlanSaved(planName _: String, data _: RaceNutritionResultAnalyticsData) {}
    public func trackEditPlanClick() {}
    public func trackToggleSelectedItems(expanded _: Bool) {}
}
