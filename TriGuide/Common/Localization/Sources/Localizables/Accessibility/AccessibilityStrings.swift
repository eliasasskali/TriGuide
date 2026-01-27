//
// TriGuide 2026
//

import Foundation

public extension Localizables {
    enum AccessibilityHints {
        // MARK: - Common

        public static var loading: String {
            String(localized: "accessibility_hints_loading", bundle: .module)
        }

        public static var disabled: String {
            String(localized: "accessibility_hints_disabled", bundle: .module)
        }

        public static func tapTo(_ action: String) -> String {
            String(
                format: String(
                    localized: "accessibility_hints_tap-to",
                    bundle: .module
                ),
                action
            )
        }
    }
}
