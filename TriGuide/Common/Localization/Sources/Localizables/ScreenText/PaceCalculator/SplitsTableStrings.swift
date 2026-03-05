//
//  TriGuide 2025
//

import Foundation

public extension Localizables {
    enum SplitsTable {
        public static var tableTitle: String {
            NSLocalizedString("splits_table-title", bundle: .module, comment: "")
        }

        public static var byDistance: String {
            NSLocalizedString("splits_table-by-distance", bundle: .module, comment: "")
        }

        public static var columnNameDistance: String {
            NSLocalizedString("splits_table-column-name-distance", bundle: .module, comment: "")
        }

        public static var columnNameSplitTime: String {
            NSLocalizedString("splits_table-column-name-split-time", bundle: .module, comment: "")
        }

        public static var columnNameCumulativeTime: String {
            NSLocalizedString("splits_table-column-name-cumulative-time", bundle: .module, comment: "")
        }
    }
}
