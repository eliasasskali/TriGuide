//
// TriGuide 2026
//

import RaceNutritionSPM

struct RaceNutritionCalculatorAnalyticsDefault: RaceNutritionCalculatorAnalyticsService {
    func trackScreenView() {}

    func trackUseTimeCalculatorClick() {}

    func trackAdvancedOptionsClick() {}

    func trackResetClick() {}

    func trackCarbInputModeChange(mode _: String) {}

    func trackCalculateClick() {}

    func trackCalculateFinished(analyticsData _: RaceNutritionCalculatorAnalyticsData) {}
}
