//
// TriGuide 2026
//

import Foundation

/// A no-op implementation of `RaceNutritionCalculatorAnalyticsService` that does nothing when its methods are called.
public struct RaceNutritionCalculatorAnalyticsServiceNoOp: RaceNutritionCalculatorAnalyticsService {
    public func trackScreenView() {}
    public func trackUseTimeCalculatorClick() {}
    public func trackAdvancedOptionsClick() {}
    public func trackResetClick() {}
    public func trackCarbInputModeChange(mode _: String) {}
    public func trackCalculateClick() {}
    public func trackCalculateFinished(analyticsData _: RaceNutritionCalculatorAnalyticsData) {}
}
