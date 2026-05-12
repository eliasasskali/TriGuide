//
// TriGuide 2025
//

import Foundation

public extension Localizables {
    enum RaceNutritionCalculator {
        public static var title: String {
            NSLocalizedString("race_nutrition_calculator-title", bundle: .module, comment: "")
            // Race Fueling Calculator
        }

        public static var subTitle: String {
            NSLocalizedString("race_nutrition_calculator-sub-title", bundle: .module, comment: "")
            // Estimate your carbohydrate needs based on race time, effort, or direct carb input.
        }

        public static var firstSectionTitle: String {
            NSLocalizedString("race_nutrition_calculator-first-section-title", bundle: .module, comment: "")
            // 1. Select your sport and race duration
        }

        public static var secondSectionTitle: String {
            NSLocalizedString("race_nutrition_calculator-second-section-title", bundle: .module, comment: "")
            // 2. Enter your target carb intake (g/h), or estimate it from your weight and effort level.
        }

        public static var duration: String {
            NSLocalizedString("race_nutrition_calculator-duration", bundle: .module, comment: "")
            // Duration
        }

        public static var selectSport: String {
            NSLocalizedString("race_nutrition_calculator-select-sport", bundle: .module, comment: "")
            // Select Sport
        }

        public static var useTimeCalculator: String {
            NSLocalizedString("race_nutrition_calculator-use-time-calculator", bundle: .module, comment: "")
            // Use Time Calculator
        }

        public static var gramsPerHourEstimateSelectSportError: String {
            NSLocalizedString("race_nutrition_calculator-grams-per-hour-estimate-select-sport-error", bundle: .module, comment: "")
            // Please select a sport before estimating carbs per hour.
        }

        public static var gramsPerHour: String {
            NSLocalizedString("race_nutrition_calculator-grams-per-hour", bundle: .module, comment: "")
            // Carbs (g/h)
        }

        public static var weightKg: String {
            NSLocalizedString("race_nutrition_calculator-weight-kg", bundle: .module, comment: "")
            // Weight (kg)
        }

        public static var estimatedTotalCarbs: String {
            NSLocalizedString("race_nutrition_calculator-estimated-total-carbs", bundle: .module, comment: "")
            // Estimated Total Carbs
        }

        public static var calculateButtonTitle: String {
            NSLocalizedString("race_nutrition_calculator-calculate-button-title", bundle: .module, comment: "")
            // Calculate
        }

        public static var advancedOptions: String {
            NSLocalizedString("race_nutrition_calculator-advanced-options", bundle: .module, comment: "")
            // Advanced Options
        }

        public static var estimateFromWeight: String {
            NSLocalizedString("race_nutrition_calculator-estimate-from-weight", bundle: .module, comment: "")
            // Estimate
        }

        public static var estimatedCarbsPerHour: String {
            NSLocalizedString("race_nutrition_calculator-estimated-carbs-per-hour", bundle: .module, comment: "")
            // Estimated: %@ g/h
        }

        public static var noCarbsNeededTitle: String {
            NSLocalizedString("race_nutrition_calculator-no-carbs-needed-title", bundle: .module, comment: "")
            // No carbs needed for this duration
        }

        public static var noCarbsNeededDescription: String {
            NSLocalizedString("race_nutrition_calculator-no-carbs-needed-description", bundle: .module, comment: "")
            // Your glycogen stores are enough for this session. If you still want to fuel, set a custom amount manually.
        }

        public static var fastedState: String {
            NSLocalizedString("race_nutrition_calculator-fasted-state", bundle: .module, comment: "")
            // Fasted State
        }

        public static var ambientTemperatureC: String {
            NSLocalizedString("race_nutrition_calculator-ambient-temperature-c", bundle: .module, comment: "")
            // Ambient Temperature (°C)
        }

        public static var ambientTemperature: String {
            NSLocalizedString("race_nutrition_calculator-ambient-temperature", bundle: .module, comment: "")
            // Ambient Temperature
        }

        public static var startEatingAt: String {
            NSLocalizedString("race_nutrition_calculator-start-eating-at", bundle: .module, comment: "")
            // Start Eating At
        }

        public static var consumedCaffeineBefore: String {
            NSLocalizedString("race_nutrition_calculator-consumed-caffeine-before", bundle: .module, comment: "")
            // Consumed Caffeine before effort
        }

        public static var carbsEstimationInformationTitle: String {
            NSLocalizedString("race_nutrition_calculator-carbs-estimation-information-title", bundle: .module, comment: "")
        } // Carbohydrate Intake Estimation

        public static var carbsEstimationInformationDescription: String {
            NSLocalizedString("race_nutrition_calculator-carbs-estimation-information-description", bundle: .module, comment: "")
        } // These recommendations are a guide, especially for athletes without gut training. Everyone’s tolerance is different, so it’s best to experiment and find what works for you.

        public static var fastedStateInformationDescription: String {
            NSLocalizedString("race_nutrition_calculator-fasted-state-information-description", bundle: .module, comment: "")
        } // Training or racing in a fasted state shifts your body toward burning more fat, so your carb needs are lower. Use this if you haven’t eaten recently.

        public static var ambientTemperatureInformationDescription: String {
            NSLocalizedString("race_nutrition_calculator-ambient-temperatur-information-description", bundle: .module, comment: "")
        } // Hotter conditions increase carb usage slightly. Your body relies more on carbs to maintain performance in heat.

        public static var startEatingAtInformationDescription: String {
            NSLocalizedString("race_nutrition_calculator-start-eating-at-information-description", bundle: .module, comment: "")
        } // Set when you want to begin your carb intake during the session.

        public static var consumedCaffeineBeforeInformationDescription: String {
            NSLocalizedString("race_nutrition_calculator-consumed-caffeine-before-information-description", bundle: .module, comment: "")
        } // Turn this on if you had caffeine before starting. This helps distribute in-session caffeine more effectively.
    }
}
