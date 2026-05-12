//
// TriGuide 2026
//

import Foundation

public extension Localizables {
    enum Errors {
        // Common

        public static var generic: String {
            NSLocalizedString("errors_generic", bundle: .module, comment: "")
        }

        // Carb Items

        public static var carbItemsDuplicateItem: String {
            NSLocalizedString("errors_carb-items-duplicate-item", bundle: .module, comment: "")
        }

        public static var carbItemsLoadingFailed: String {
            NSLocalizedString("errors_carb-items-loading-failed", bundle: .module, comment: "")
        }

        // Fueling Plan

        public static var fuelingPlanDuplicateItem: String {
            NSLocalizedString("errors_fueling-plan-duplicate-item", bundle: .module, comment: "")
        }

        public static var fuelingPlanSaveFailed: String {
            NSLocalizedString("errors_fueling-plan-save-failed", bundle: .module, comment: "")
        }

        // Couldn't delete the plan. Please try again.
        public static var fuelingPlanDeleteFailed: String {
            NSLocalizedString("errors_fueling-plan-delete-failed", bundle: .module, comment: "")
        }
    }
}
