//
// TriGuide 2025
//

import Foundation

public extension Localizables {
    enum RaceNutritionCalculator {
        public static var title: String {
            String(localized: "race_nutrition_calculator-title", bundle: .module)
            // Race Fueling Calculator
        }

        public static var subTitle: String {
            String(localized: "race_nutrition_calculator-sub-title", bundle: .module)
            // Estimate your carbohydrate needs based on race time, effort, or direct carb input.
        }

        public static var firstSectionTitle: String {
            String(localized: "race_nutrition_calculator-first-section-title", bundle: .module)
            // 1. Select your sport and race duration
        }

        public static var secondSectionTitle: String {
            String(localized: "race_nutrition_calculator-second-section-title", bundle: .module)
            // 2. Choose how to estimate carbs per hour
        }

        public static var secondSectionDescription: String {
            String(localized: "race_nutrition_calculator-second-section-description", bundle: .module)
            // Enter your target carb intake (g/h), or estimate it from your weight and effort level.
        }

        public static var duration: String {
            String(localized: "race_nutrition_calculator-duration", bundle: .module)
            // Duration
        }

        public static var selectSport: String {
            String(localized: "race_nutrition_calculator-select-sport", bundle: .module)
            // Select Sport
        }

        public static var useTimeCalculator: String {
            String(localized: "race_nutrition_calculator-use-time-calculator", bundle: .module)
            // Use Time Calculator
        }

        public static var paceCalculatorSelectSportError: String {
            String(localized: "race_nutrition_calculator-pace-calculator-select-sport-error", bundle: .module)
            // Please select a sport before using the time calculator.
        }

        public static var gramsPerHourEstimateSelectSportError: String {
            String(localized: "race_nutrition_calculator-grams-per-hour-estimate-select-sport-error", bundle: .module)
            // Please select a sport before estimating carbs per hour.
        }

        public static var gramsPerHour: String {
            String(localized: "race_nutrition_calculator-grams-per-hour", bundle: .module)
            // Carbs (g/h)
        }

        public static var weightKg: String {
            String(localized: "race_nutrition_calculator-weight-kg", bundle: .module)
            // Weight (kg)
        }

        public static var estimatedTotalCarbs: String {
            String(localized: "race_nutrition_calculator-estimated-total-carbs", bundle: .module)
            // Estimated Total Carbs
        }

        public static var calculateButtonTitle: String {
            String(localized: "race_nutrition_calculator-calculate-button-title", bundle: .module)
            // Calculate
        }

        public static var advancedOptions: String {
            String(localized: "race_nutrition_calculator-advanced-options", bundle: .module)
            // Advanced Options
        }

        public static var fastedState: String {
            String(localized: "race_nutrition_calculator-fasted-state", bundle: .module)
            // Fasted State
        }

        public static var gutTrained: String {
            String(localized: "race_nutrition_calculator-gut-trained", bundle: .module)
            // Gut trained
        }

        public static var applyAmateurLimits: String {
            String(localized: "race_nutrition_calculator-apply-amateur-limits", bundle: .module)
            // Apply amateur limits
        }

        public static var ambientTemperatureC: String {
            String(localized: "race_nutrition_calculator-ambient-temperature-c", bundle: .module)
            // Ambient Temperature (°C)
        }

        public static var ambientTemperature: String {
            String(localized: "race_nutrition_calculator-ambient-temperature", bundle: .module)
            // Ambient Temperature
        }

        public static var carbsEstimationInformationTitle: String {
            String(localized: "race_nutrition_calculator-carbs-estimation-information-title", bundle: .module)
        } // Carbohydrate Intake Estimation

        public static var carbsEstimationInformationDescription: String {
            String(localized: "race_nutrition_calculator-carbs-estimation-information-description", bundle: .module)
        } // These recommendations are a guide, especially for athletes without gut training. Everyone’s tolerance is different, so it’s best to experiment and find what works for you.

        public static var fastedStateInformationDescription: String {
            String(localized: "race_nutrition_calculator-fasted-state-information-description", bundle: .module)
        } // Training or racing in a fasted state shifts your body toward burning more fat, so your carb needs are lower. Use this if you haven’t eaten recently.

        public static var gutTrainedInformationDescription: String {
            String(localized: "race_nutrition_calculator-gut-trained-information-description", bundle: .module)
        } // You can train your gut to tolerate more carbs during long sessions. Start gradually with small amounts and increase over time to avoid discomfort.

        public static var applyAmateurLimitsInformationDescription: String {
            String(localized: "race_nutrition_calculator-apply-amateur-limits-information-description", bundle: .module)
        } // The carb recommendation is capped for safety, ideal for athletes without gut training. Advanced users can disable this in settings.

        public static var ambientTemperatureInformationDescription: String {
            String(localized: "race_nutrition_calculator-ambient-temperatur-information-description", bundle: .module)
        } // Hotter conditions increase carb usage slightly. Your body relies more on carbs to maintain performance in heat.
    }
}
