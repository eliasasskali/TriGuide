//
//  TriGuide 2025
//

import Foundation

public extension Localizables {
    enum RaceDistance {
        // MARK: - Running

        public static var halfMarathon: String {
            String(localized: "raceDistance_half-marathon", bundle: .module)
        }

        public static var marathon: String {
            String(localized: "raceDistance_marathon", bundle: .module)
        }

        // MARK: - Triathlon

        public static var supersprint: String {
            String(localized: "raceDistance_supersprint", bundle: .module)
        }

        public static var sprint: String {
            String(localized: "raceDistance_sprint", bundle: .module)
        }

        public static var triathlonOlympic: String {
            String(localized: "raceDistance_triathlon-olympic", bundle: .module)
        }

        public static var triathlonMiddle: String {
            String(localized: "raceDistance_triathlon-middle", bundle: .module)
        }

        public static var triathlonFull: String {
            String(localized: "raceDistance_triathlon-full", bundle: .module)
        }

        // MARK: - Duathlon

        public static var duathlonStandard: String {
            String(localized: "raceDistance_duathlon-standard", bundle: .module)
        }

        public static var duathlonMiddle: String {
            String(localized: "raceDistance_duathlon-middle", bundle: .module)
        }

        public static var duathlonLong: String {
            String(localized: "raceDistance_duathlon-long", bundle: .module)
        }
    }
}
