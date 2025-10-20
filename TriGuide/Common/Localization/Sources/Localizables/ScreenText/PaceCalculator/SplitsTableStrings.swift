//
//  TriGuide 2025
//

import Foundation

public extension Localizables {
    enum SplitsTable {
        public static var tableTitle: String {
            String(localized: "splits_table-title", bundle: .module)
        }
        
        public static var byDistance: String {
            String(localized: "splits_table-by-distance", bundle: .module)
        }
        
        public static var columnNameDistance: String {
            String(localized: "splits_table-column-name-distance", bundle: .module)
        }
        
        public static var columnNameSplitTime: String {
            String(localized: "splits_table-column-name-split-time", bundle: .module)
        }
        
        public static var columnNameCumulativeTime: String {
            String(localized: "splits_table-column-name-cumulative-time", bundle: .module)
        }
    }
}
