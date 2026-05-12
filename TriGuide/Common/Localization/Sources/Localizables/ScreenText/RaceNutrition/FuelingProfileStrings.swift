//
// TriGuide 2025
//

import Foundation

public extension Localizables {
    enum FuelingProfile {
        public static var amateur: String {
            NSLocalizedString("fueling_profile_amateur", bundle: .module, comment: "")
            // Amateur
        }

        public static var trained: String {
            NSLocalizedString("fueling_profile_trained", bundle: .module, comment: "")
            // Trained gut
        }

        public static var uncapped: String {
            NSLocalizedString("fueling_profile_uncapped", bundle: .module, comment: "")
            // No limits
        }

        public static var title: String {
            NSLocalizedString("fueling_profile_title", bundle: .module, comment: "")
            // Fueling profile
        }

        public static var informationDescription: String {
            NSLocalizedString("fueling_profile_information_description", bundle: .module, comment: "")
            // Amateur applies conservative caps. Trained gut raises the cap for athletes who've adapted their digestion. No limits removes all caps.
        }
    }
}
