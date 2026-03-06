//
// TriGuide 2025
//

import Foundation

public extension Localizables {
    enum CarbItems {
        public static var title: String {
            NSLocalizedString("carbItems_title", bundle: .module, comment: "")
        }

        public static var userItemsSectionTitle: String {
            NSLocalizedString("carbItems_user_items_section_title", bundle: .module, comment: "")
        }

        public static var allItemsSectionTitle: String {
            NSLocalizedString("carbItems_all_items_section_title", bundle: .module, comment: "")
        }

        public static var carbsLabel: String {
            NSLocalizedString("carbItems_carbs_label", bundle: .module, comment: "")
        }

        public static func carbsValue(grams: Double) -> String {
            String(
                format: NSLocalizedString("carbItems_carbs_value", bundle: .module, comment: ""),
                grams
            )
        }

        public static var caffeineLabel: String {
            NSLocalizedString("carbItems_caffeine_label", bundle: .module, comment: "")
        }

        public static func caffeineValue(caffeine: Double) -> String {
            String(
                format: NSLocalizedString("carbItems_caffeine_value", bundle: .module, comment: ""),
                caffeine
            )
        }

        public static var volumeLabel: String {
            NSLocalizedString("carbItems_volume_label", bundle: .module, comment: "")
        }

        public static func volumeValue(miliLiters: Double) -> String {
            String(
                format: NSLocalizedString("carbItems_volume_value", bundle: .module, comment: ""),
                miliLiters
            )
        }

        public static var sodiumLabel: String {
            NSLocalizedString("carbItems_sodium_label", bundle: .module, comment: "")
        }

        public static func sodiumValue(miliGrams: Double) -> String {
            String(
                format: NSLocalizedString("carbItems_sodium_value", bundle: .module, comment: ""),
                miliGrams
            )
        }

        // MARK: - Types

        public static var typeSolid: String {
            NSLocalizedString("carbItems-type-solid", bundle: .module, comment: "")
        }

        public static var typeDrink: String {
            NSLocalizedString("carbItems-type-drink", bundle: .module, comment: "")
        }

        public static var typeGel: String {
            NSLocalizedString("carbItems-type-gel", bundle: .module, comment: "")
        }

        public static var typeOther: String {
            NSLocalizedString("carbItems-type-other", bundle: .module, comment: "")
        }
    }
}
