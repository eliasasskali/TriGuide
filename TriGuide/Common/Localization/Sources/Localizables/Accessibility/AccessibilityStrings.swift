//
// TriGuide 2026
//

import Foundation

public extension Localizables {
    enum AccessibilityHints {
        // MARK: - Common

        public static var loading: String {
            NSLocalizedString("accessibility_hints_loading", bundle: .module, comment: "")
        }

        public static var disabled: String {
            NSLocalizedString("accessibility_hints_disabled", bundle: .module, comment: "")
        }

        public static func tapTo(_ action: String) -> String {
            String(
                format: NSLocalizedString("accessibility_hints_tap-to", bundle: .module, comment: ""),
                action
            )
        }
    }
}
