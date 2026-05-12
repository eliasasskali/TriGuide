//
//  TriGuide 2025
//

import Foundation

public extension Localizables {
    enum RaceDistance {
        // MARK: - Running

        public static var halfMarathon: String {
            NSLocalizedString("raceDistance_half-marathon", bundle: .module, comment: "")
        }

        public static var marathon: String {
            NSLocalizedString("raceDistance_marathon", bundle: .module, comment: "")
        }

        // MARK: - Triathlon

        public static var supersprint: String {
            NSLocalizedString("raceDistance_supersprint", bundle: .module, comment: "")
        }

        public static var sprint: String {
            NSLocalizedString("raceDistance_sprint", bundle: .module, comment: "")
        }

        public static var triathlonOlympic: String {
            NSLocalizedString("raceDistance_triathlon-olympic", bundle: .module, comment: "")
        }

        public static var triathlonMiddle: String {
            NSLocalizedString("raceDistance_triathlon-middle", bundle: .module, comment: "")
        }

        public static var triathlonFull: String {
            NSLocalizedString("raceDistance_triathlon-full", bundle: .module, comment: "")
        }

        // MARK: - Duathlon

        public static var duathlonStandard: String {
            NSLocalizedString("raceDistance_duathlon-standard", bundle: .module, comment: "")
        }

        public static var duathlonMiddle: String {
            NSLocalizedString("raceDistance_duathlon-middle", bundle: .module, comment: "")
        }

        public static var duathlonLong: String {
            NSLocalizedString("raceDistance_duathlon-long", bundle: .module, comment: "")
        }
    }
}
