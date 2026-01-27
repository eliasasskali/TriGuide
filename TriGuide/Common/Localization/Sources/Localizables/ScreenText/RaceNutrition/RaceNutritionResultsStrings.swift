//
// TriGuide 2026
//

import Foundation

public extension Localizables {
    enum RaceNutritionResults {
        // MARK: - Instant Events editor

        // Instant fueling events
        public static let instantEventsTitle: String = .init(
            localized: "race_nutrition_results-instant-events-title",
            bundle: .module
        )

        // MARK: - Interval Events editor

        // Interval fueling events
        public static let intervalEventsTitle: String = .init(
            localized: "race_nutrition_results-interval-events-title",
            bundle: .module
        )

        // MARK: - Interval Breakdown

        // Interval %@
        public static func interval(_ interval: String) -> String {
            String(
                format: String(
                    localized: "race_nutrition_results-interval-breakdown-interval",
                    bundle: .module
                ),
                interval
            )
        }

        // Carbs:
        public static let intervalCarbsLabel: String = .init(
            localized: "race_nutrition_results-interval-carbs-label",
            bundle: .module
        )

        // Caffeine:
        public static let intervalCaffeineLabel: String = .init(
            localized: "race_nutrition_results-interval-caffeine-label",
            bundle: .module
        )

        // Líquid:
        public static let intervalLiquidLabel: String = .init(
            localized: "race_nutrition_results-interval-liquid-label",
            bundle: .module
        )

        // MARK: - Fueling plan edit View

        // Hourly breakdown
        public static let editViewHourlyBreakdownTitle: String = .init(
            localized: "race_nutrition_results-edit-view-hourly-breakdown-title",
            bundle: .module
        )

        // Reset
        public static let editViewResetButtonLabel: String = .init(
            localized: "race_nutrition_results-edit-view-reset-button-label",
            bundle: .module
        )

        // Apply changes
        public static let editViewApplyButtonLabel: String = .init(
            localized: "race_nutrition_results-edit-view-apply-button-label",
            bundle: .module
        )

        // MARK: - Result View

        // Fueling plan
        public static let fuelingPlanTitle: String = .init(
            localized: "race_nutrition_results-fueling-plan-title",
            bundle: .module
        )

        // Edit
        public static let fuelingPlanEditButtonLabel: String = .init(
            localized: "race_nutrition_results-fueling-plan-edit-button-label",
            bundle: .module
        )

        // Time
        public static let fuelingPlanTimeColumnTitle: String = .init(
            localized: "race_nutrition_results-fueling-plan-time-column-title",
            bundle: .module
        )

        // Item
        public static let fuelingPlanItemColumnTitle: String = .init(
            localized: "race_nutrition_results-fueling-plan-item-column-title",
            bundle: .module
        )

        // Interval
        public static let fuelingPlanIntervalColumnTitle: String = .init(
            localized: "race_nutrition_results-fueling-plan-interval-column-title",
            bundle: .module
        )

        // Drink
        public static let fuelingPlanDrinkColumnTitle: String = .init(
            localized: "race_nutrition_results-fueling-plan-drink-column-title",
            bundle: .module
        )

        // Selected Carbs/Target:
        public static let fuelingPlanSelectedCarbsTargetLabel: String = .init(
            localized: "race_nutrition_results-fueling-plan-selected-carbs-target-label",
            bundle: .module
        )

        // Selected Carbs per Hour/Target:
        public static let fuelingPlanSelectedCarbsHourTargetLabel: String = .init(
            localized: "race_nutrition_results-fueling-plan-selected-carbs-hour-target-label",
            bundle: .module
        )

        // Selected Nutrition Items
        public static let fuelingPlanSelectedNutritionItemsTitle: String = .init(
            localized: "race_nutrition_results-fueling-plan-selected-nutrition-items-title",
            bundle: .module
        )

        // Hourly breakdown
        public static let fuelingPlanHourlyBreakdownTitle: String = .init(
            localized: "race_nutrition_results-fueling-plan-hourly-breakdown-title",
            bundle: .module
        )
    }
}
