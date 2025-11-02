//
// TriGuide 2025
//

import Foundation

public extension Localizables {
    enum CarbItems {
        public static var title: String {
            String(localized: "carbItems_title", bundle: .module)
        }

        public static var carbsLabel: String {
            String(localized: "carbItems_carbs_label", bundle: .module)
        }

        public static var carbsLabelShort: String {
            String(localized: "carbItems_carbs_label_short", bundle: .module)
        }

        public static func carbsValue(grams: Double) -> String {
            String(
                format: String(
                    localized: "carbItems_carbs_value",
                    bundle: .module
                ),
                grams
            )
        }

        public static var caffeineLabel: String {
            String(localized: "carbItems_caffeine_label", bundle: .module)
        }

        public static var caffeineLabelShort: String {
            String(localized: "carbItems_caffeine_label_short", bundle: .module)
        }

        public static func caffeineValue(caffeine: Double) -> String {
            String(
                format: String(
                    localized: "carbItems_caffeine_value",
                    bundle: .module
                ),
                caffeine
            )
        }

        public static var volumeLabel: String {
            String(localized: "carbItems_volume_label", bundle: .module)
        }

        public static var volumeLabelShort: String {
            String(localized: "carbItems_volume_label_short", bundle: .module)
        }

        public static func volumeValue(miliLiters: Double) -> String {
            String(
                format: String(
                    localized: "carbItems_volume_value",
                    bundle: .module
                ),
                miliLiters
            )
        }

        public static var sodiumLabel: String {
            String(localized: "carbItems_sodium_label", bundle: .module)
        }

        public static func sodiumValue(miliGrams: Double) -> String {
            String(
                format: String(
                    localized: "carbItems_sodium_value",
                    bundle: .module
                ),
                miliGrams
            )
        }
    }
}
