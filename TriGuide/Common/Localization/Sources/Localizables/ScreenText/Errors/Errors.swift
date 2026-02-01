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
    }
}
