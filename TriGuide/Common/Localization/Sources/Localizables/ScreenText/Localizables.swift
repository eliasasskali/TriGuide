//
//  TriGuide 2025
//

import Foundation

public enum Localizables {
    // MARK: - Common

    public enum Common {
        public static var done: String {
            NSLocalizedString("done", bundle: .module, comment: "")
        }

        public static var sport: String {
            NSLocalizedString("sport", bundle: .module, comment: "")
        }

        public static var save: String {
            NSLocalizedString("save", bundle: .module, comment: "")
        }

        public static var delete: String {
            NSLocalizedString("delete", bundle: .module, comment: "")
        }

        public static var edit: String {
            NSLocalizedString("edit", bundle: .module, comment: "")
        }

        public static var addToFavorites: String {
            NSLocalizedString("add_to_favorites", bundle: .module, comment: "")
        }

        public static var removeFromFavorites: String {
            NSLocalizedString("remove_from_favorites", bundle: .module, comment: "")
        }

        public static var intensity: String {
            NSLocalizedString("intensity", bundle: .module, comment: "")
        }

        public static var continueLabel: String {
            NSLocalizedString("continue", bundle: .module, comment: "")
        }

        public static var error: String {
            NSLocalizedString("error", bundle: .module, comment: "")
        }

        public static var ok: String {
            NSLocalizedString("ok", bundle: .module, comment: "")
        }

        public static var cancel: String {
            NSLocalizedString("cancel", bundle: .module, comment: "")
        }

        public static var reset: String {
            NSLocalizedString("reset", bundle: .module, comment: "")
        }
    }

    // MARK: - App tabs

    public enum Tabs {
        public static var calculator: String {
            NSLocalizedString("tabs_calculator", bundle: .module, comment: "")
        }

        public static var sportNutrition: String {
            NSLocalizedString("tabs_sport_nutrition", bundle: .module, comment: "")
        }

        public static var myAthleteProfile: String {
            NSLocalizedString("tabs_my_athlete_profile", bundle: .module, comment: "")
        }
    }
}
