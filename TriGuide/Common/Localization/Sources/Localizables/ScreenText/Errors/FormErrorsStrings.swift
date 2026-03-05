//
// TriGuide 2025
//

import Foundation

public extension Localizables {
    enum FormErrors {
        public static var requiredField: String {
            NSLocalizedString("formErrors_required_field", bundle: .module, comment: "")
        }

        public static var invalidNumber: String {
            NSLocalizedString("formErrors_invalid_number", bundle: .module, comment: "")
        }

        public static var invalidFormat: String {
            NSLocalizedString("formErrors_invalid_format", bundle: .module, comment: "")
        }

        public static var outOfRange: String {
            NSLocalizedString("formErrors_out_of_range", bundle: .module, comment: "")
        }

        public static func betweenMinAndMax(min: Double, max: Double) -> String {
            String(
                format: NSLocalizedString("formErrors_between_min_and_max", bundle: .module, comment: ""),
                min,
                max
            )
        }

        public static func biggerThan(min: Double) -> String {
            String(
                format: NSLocalizedString("formErrors_bigger_than_min", bundle: .module, comment: ""),
                min
            )
        }

        public static func smallerThan(max: Double) -> String {
            String(
                format: NSLocalizedString("formErrors_smaller_than_max", bundle: .module, comment: ""),
                max
            )
        }
    }
}
