//
// TriGuide 2026
//

import Foundation

public extension Localizables {
    enum RaceNutritionResults {
        public static let savePlanButtonLabel: String = NSLocalizedString(
            "race_nutrition_results-save-plan-button-label",
            bundle: .module,
            comment: ""
        )

        public static let saveSuccessToastMessage: String = NSLocalizedString(
            "race_nutrition_results-save-success-toast-message",
            bundle: .module,
            comment: ""
        )

        public static let savePlanButtonHint: String = NSLocalizedString(
            "race_nutrition_results-save-plan-button-hint",
            bundle: .module,
            comment: ""
        )

        // Plan name
        public static let savePlanNamePlaceholder: String = NSLocalizedString(
            "race_nutrition_results-save-plan-name-placeholder",
            bundle: .module,
            comment: ""
        )

        // MARK: - Instant Events editor

        // Instant fueling events
        public static let instantEventsTitle: String = NSLocalizedString(
            "race_nutrition_results-instant-events-title",
            bundle: .module,
            comment: ""
        )

        // MARK: - Interval Events editor

        // Interval fueling events
        public static let intervalEventsTitle: String = NSLocalizedString(
            "race_nutrition_results-interval-events-title",
            bundle: .module,
            comment: ""
        )

        // MARK: - Interval Breakdown

        // Interval %@
        public static func interval(_ interval: String) -> String {
            String(
                format: NSLocalizedString(
                    "race_nutrition_results-interval-breakdown-interval",
                    bundle: .module,
                    comment: ""
                ),
                interval
            )
        }

        // Carbs:
        public static let intervalCarbsLabel: String = NSLocalizedString(
            "race_nutrition_results-interval-carbs-label",
            bundle: .module,
            comment: ""
        )

        // Caffeine:
        public static let intervalCaffeineLabel: String = NSLocalizedString(
            "race_nutrition_results-interval-caffeine-label",
            bundle: .module,
            comment: ""
        )

        // Líquid:
        public static let intervalLiquidLabel: String = NSLocalizedString(
            "race_nutrition_results-interval-liquid-label",
            bundle: .module,
            comment: ""
        )

        // MARK: - Fueling plan edit View

        // Hourly breakdown
        public static let editViewHourlyBreakdownTitle: String = NSLocalizedString(
            "race_nutrition_results-edit-view-hourly-breakdown-title",
            bundle: .module,
            comment: ""
        )

        // Reset
        public static let editViewResetButtonLabel: String = NSLocalizedString(
            "race_nutrition_results-edit-view-reset-button-label",
            bundle: .module,
            comment: ""
        )

        // Apply changes
        public static let editViewApplyButtonLabel: String = NSLocalizedString(
            "race_nutrition_results-edit-view-apply-button-label",
            bundle: .module,
            comment: ""
        )

        // MARK: - Result View

        // Fueling plan
        public static let fuelingPlanTitle: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-title",
            bundle: .module,
            comment: ""
        )

        // Edit
        public static let fuelingPlanEditButtonLabel: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-edit-button-label",
            bundle: .module,
            comment: ""
        )

        // Time
        public static let fuelingPlanTimeColumnTitle: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-time-column-title",
            bundle: .module,
            comment: ""
        )

        // Item
        public static let fuelingPlanItemColumnTitle: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-item-column-title",
            bundle: .module,
            comment: ""
        )

        // Interval
        public static let fuelingPlanIntervalColumnTitle: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-interval-column-title",
            bundle: .module,
            comment: ""
        )

        // Drink
        public static let fuelingPlanDrinkColumnTitle: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-drink-column-title",
            bundle: .module,
            comment: ""
        )

        // Selected Carbs/Target:
        public static let fuelingPlanSelectedCarbsTargetLabel: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-selected-carbs-target-label",
            bundle: .module,
            comment: ""
        )

        // Selected Carbs per Hour/Target:
        public static let fuelingPlanSelectedCarbsHourTargetLabel: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-selected-carbs-hour-target-label",
            bundle: .module,
            comment: ""
        )

        // Selected Nutrition Items
        public static let fuelingPlanSelectedNutritionItemsTitle: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-selected-nutrition-items-title",
            bundle: .module,
            comment: ""
        )

        // Hourly breakdown
        public static let fuelingPlanHourlyBreakdownTitle: String = NSLocalizedString(
            "race_nutrition_results-fueling-plan-hourly-breakdown-title",
            bundle: .module,
            comment: ""
        )

        // Stored fueling plans
        public static let storedPlansTitle: String = NSLocalizedString(
            "race_nutrition_results-stored-plans-title",
            bundle: .module,
            comment: ""
        )

        // No stored plans
        public static let storedPlansNoStoredPlans: String = NSLocalizedString(
            "race_nutrition_results-stored-plans-no-stored-plans",
            bundle: .module,
            comment: ""
        )

        // Unnamed plan
        public static let storedPlansItemUnnamedPlan: String = NSLocalizedString(
            "race_nutrition_results-stored-plans-item-unnamed-plan",
            bundle: .module,
            comment: ""
        )

        // Duration
        public static let storedPlansItemDurationLabel: String = NSLocalizedString(
            "race_nutrition_results-stored-plans-item-duration-label",
            bundle: .module,
            comment: ""
        )

        // Grams/h
        public static let storedPlansItemGramsHourLabel: String = NSLocalizedString(
            "race_nutrition_results-stored-plans-item-grams-hour-label",
            bundle: .module,
            comment: ""
        )

        // %d g/h
        public static func storedPlansItemGramsHourValue(_ value: Int) -> String {
            String(
                format: NSLocalizedString(
                    "race_nutrition_results-stored-plans-item-grams-hour-value",
                    bundle: .module,
                    comment: ""
                ),
                value
            )
        }
    }
}
