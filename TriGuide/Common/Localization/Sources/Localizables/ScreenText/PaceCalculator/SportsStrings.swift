//
//  TriGuide 2025
//

import Foundation

public extension Localizables {
    enum Sports {
        public static var swimming: String {
            String(localized: "sports_swimming", bundle: .module)
        }

        public static var cycling: String {
            String(localized: "sports_cycling", bundle: .module)
        }

        public static var running: String {
            String(localized: "sports_running", bundle: .module)
        }

        public static var triathlon: String {
            String(localized: "sports_triathlon", bundle: .module)
        }

        public static var duathlon: String {
            String(localized: "sports_duathlon", bundle: .module)
        }
    }
}
