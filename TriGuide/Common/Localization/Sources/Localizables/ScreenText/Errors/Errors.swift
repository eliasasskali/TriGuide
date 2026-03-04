//
// TriGuide 2026
//

import Foundation

public extension Localizables {
    enum Errors {
        // Common

        public static var generic: String {
            String(localized: "errors_generic", bundle: .module)
        }

        // Carb Items

        public static var carbItemsDuplicateItem: String {
            String(localized: "errors_carb-items-duplicate-item", bundle: .module)
        }

        public static var carbItemsLoadingFailed: String {
            String(localized: "errors_carb-items-loading-failed", bundle: .module)
        }

        // Fueling Plan

        public static var fuelingPlanDuplicateItem: String {
            String(localized: "errors_fueling-plan-duplicate-item", bundle: .module)
        }

        public static var fuelingPlanSaveFailed: String {
            String(localized: "errors_fueling-plan-save-failed", bundle: .module)
        }

        // Couldn't delete the plan. Please try again.
        public static var fuelingPlanDeleteFailed: String {
            String(localized: "errors_fueling-plan-delete-failed", bundle: .module)
        }
    }
}
