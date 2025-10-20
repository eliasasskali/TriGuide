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

        public static var select: String {
            String(localized: "select", bundle: .module)
        }
        
        public static var sport: String {
            String(localized: "sport", bundle: .module)
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

        public static var materialList: String {
            String(localized: "tabs_material_list", bundle: .module)
        }
    }
}
