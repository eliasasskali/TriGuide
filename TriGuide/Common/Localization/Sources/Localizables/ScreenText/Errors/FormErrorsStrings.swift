//
// TriGuide 2025
//

import Foundation

public extension Localizables {
    enum FormErrors {
        public static var requiredField: String {
            String(localized: "formErrors_required_field", bundle: .module)
        }

        public static var invalidNumber: String {
            String(localized: "formErrors_invalid_number", bundle: .module)
        }

        public static var invalidFormat: String {
            String(localized: "formErrors_invalid_format", bundle: .module)
        }

        public static var outOfRange: String {
            String(localized: "formErrors_out_of_range", bundle: .module)
        }

        public static func betweenMinAndMax(min: Double, max: Double) -> String {
            String(
                format: String(
                    localized: "formErrors_between_min_and_max",
                    bundle: .module
                ),
                min,
                max
            )
        }

        public static func biggerThan(min: Double) -> String {
            String(
                format: String(
                    localized: "formErrors_bigger_than_min",
                    bundle: .module
                ),
                min
            )
        }

        public static func smallerThan(max: Double) -> String {
            String(
                format: String(
                    localized: "formErrors_smaller_than_max",
                    bundle: .module
                ),
                max
            )
        }
    }
}
