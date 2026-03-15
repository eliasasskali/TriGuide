//
// TriGuide 2026
//

import FirebaseAnalytics
import RaceNutritionSPM

struct RaceNutritionCalculatorAnalyticsDefault: RaceNutritionCalculatorAnalyticsService {
    // MARK: - Constants

    private enum Constants {
        static let screenName = AnalyticsEvent.Screen.raceNutritionCalculator
        static let useTimeCalculatorButtonElement = "use_time_calculator_button"
        static let advancedOptionsButtonElement = "advanced_options_button"
        static let resetElement = "reset_button"
        static let carbInputModeElement = "carb_input_mode"
        static let calculateButtonElement = "calculate_button"
    }

    // MARK: - RaceNutritionCalculatorAnalyticsService

    func trackScreenView() {
        AnalyticsEvent.screenView(screenName: Constants.screenName)
    }

    func trackUseTimeCalculatorClick() {
        AnalyticsEvent.click(
            element: Constants.useTimeCalculatorButtonElement,
            screen: Constants.screenName
        )
    }

    func trackAdvancedOptionsClick() {
        AnalyticsEvent.click(
            element: Constants.advancedOptionsButtonElement,
            screen: Constants.screenName
        )
    }

    func trackResetClick() {
        AnalyticsEvent.click(
            element: Constants.resetElement,
            screen: Constants.screenName
        )
    }

    func trackCarbInputModeChange(mode: String) {
        AnalyticsEvent.click(
            element: Constants.carbInputModeElement,
            screen: Constants.screenName,
            extraParams: ["mode": mode]
        )
    }

    func trackCalculateClick() {
        AnalyticsEvent.click(
            element: Constants.calculateButtonElement,
            screen: Constants.screenName
        )
    }

    func trackCalculateFinished(analyticsData: RaceNutritionCalculatorAnalyticsData) {
        Analytics.logEvent(
            "calculate_finished",
            parameters: [
                "screen": AnalyticsEvent.Screen.raceNutritionCalculator,
                "duration_seconds": analyticsData.durationSeconds,
                "sport": analyticsData.sport,
                "carb_input_mode": analyticsData.carbInputMode,
                "carbs_per_hour": analyticsData.carbsPerHour,
                "weight": analyticsData.estimatedGramsHourWeight as Any,
                "intensity": analyticsData.estimatedGramsHourIntensity as Any,
                "caffeine_before": analyticsData.consumedCaffeineBeforeStart,
                "fasted": analyticsData.fastedState,
                "fueling_profile": analyticsData.fuelingProfile,
                "start_carb_intake_at": analyticsData.startCarbIntakeAtSeconds,
                "ambient_temperature": analyticsData.ambientTemperature,
                "estimated_total_grams": analyticsData.estimatedTotalGrams,
            ]
        )
    }
}
