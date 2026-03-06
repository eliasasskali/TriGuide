//
//  TriGuide 2025
//

import Foundation

public extension Localizables {
    enum PaceCalculator {
        public static var distance: String {
            NSLocalizedString("paceCalculator_distance", bundle: .module, comment: "")
        }

        public static var time: String {
            NSLocalizedString("paceCalculator_time", bundle: .module, comment: "")
        }

        public static var speed: String {
            NSLocalizedString("paceCalculator_speed", bundle: .module, comment: "")
        }

        public static var pace: String {
            NSLocalizedString("paceCalculator_pace", bundle: .module, comment: "")
        }

        public static var unit: String {
            NSLocalizedString("paceCalculator_unit", bundle: .module, comment: "")
        }

        public static var triathlonDistance: String {
            NSLocalizedString("paceCalculator_triathlon-distance", bundle: .module, comment: "")
        }

        public static var duathlonDistance: String {
            NSLocalizedString("paceCalculator_duathlon-distance", bundle: .module, comment: "")
        }

        public static var race: String {
            NSLocalizedString("paceCalculator_race", bundle: .module, comment: "")
        }

        public static var totalTime: String {
            NSLocalizedString("paceCalculator_total-time", bundle: .module, comment: "")
        }

        public static func transitionTime(transitionNumber: Int) -> String {
            String(
                format: NSLocalizedString("paceCalculator_transitionX-time", bundle: .module, comment: ""),
                transitionNumber
            )
        }
    }
}
