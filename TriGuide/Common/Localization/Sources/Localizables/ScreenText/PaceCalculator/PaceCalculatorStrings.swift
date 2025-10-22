//
//  TriGuide 2025
//

import Foundation

public extension Localizables {
    enum PaceCalculator {
        public static var distance: String {
            String(localized: "paceCalculator_distance", bundle: .module)
        }

        public static var time: String {
            String(localized: "paceCalculator_time", bundle: .module)
        }

        public static var speed: String {
            String(localized: "paceCalculator_speed", bundle: .module)
        }

        public static var pace: String {
            String(localized: "paceCalculator_pace", bundle: .module)
        }

        public static var unit: String {
            String(localized: "paceCalculator_unit", bundle: .module)
        }

        public static var triathlonDistance: String {
            String(localized: "paceCalculator_triathlon-distance", bundle: .module)
        }

        public static var duathlonDistance: String {
            String(localized: "paceCalculator_duathlon-distance", bundle: .module)
        }

        public static var race: String {
            String(localized: "paceCalculator_race", bundle: .module)
        }

        public static var totalTime: String {
            String(localized: "paceCalculator_total-time", bundle: .module)
        }

        public static func transitionTime(transitionNumber: Int) -> String {
            String(
                format: String(
                    localized: "paceCalculator_transitionX-time",
                    bundle: .module
                ),
                transitionNumber
            )
        }
    }
}
