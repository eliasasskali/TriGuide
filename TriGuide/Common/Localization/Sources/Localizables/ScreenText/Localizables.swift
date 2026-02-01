//
//  TriGuide 2025
//

import Foundation

public enum Localizables {
    // MARK: - Common

    public enum Common {
        public static var done: String {
            String(localized: "done", bundle: .module)
        }

        public static var sport: String {
            String(localized: "sport", bundle: .module)
        }

        public static var save: String {
            String(localized: "save", bundle: .module)
        }

        public static var delete: String {
            String(localized: "delete", bundle: .module)
        }

        public static var edit: String {
            String(localized: "edit", bundle: .module)
        }

        public static var addToFavorites: String {
            String(localized: "add_to_favorites", bundle: .module)
        }

        public static var removeFromFavorites: String {
            String(localized: "remove_from_favorites", bundle: .module)
        }

        public static var or: String {
            String(localized: "or", bundle: .module)
        }

        public static var intensity: String {
            String(localized: "intensity", bundle: .module)
        }

        public static var continueLabel: String {
            String(localized: "continue", bundle: .module)
        }

        public static var error: String {
            String(localized: "error", bundle: .module)
        }

        public static var ok: String {
            String(localized: "ok", bundle: .module)
        }
    }

    // MARK: - App tabs

    public enum Tabs {
        public static var home: String {
            String(localized: "tabs_home", bundle: .module)
        }

        public static var calculator: String {
            String(localized: "tabs_calculator", bundle: .module)
        }

        public static var sportNutrition: String {
            String(localized: "tabs_sport_nutrition", bundle: .module)
        }
    }
}
