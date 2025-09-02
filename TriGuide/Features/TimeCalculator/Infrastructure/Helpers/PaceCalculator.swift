//
//  TriGuide 2025
//

import Foundation

protocol PaceCalculator {
    func calculatePace(
        duration: TimeInterval,
        distance: Double,
        paceUnit: SupportedUnit
    ) -> Double?

    func calculateTime(
        pace: Double,
        distance: Double,
        paceUnit: SupportedUnit
    ) -> Double?

    func formatPace(
        _ pace: Double,
        with paceUnit: SupportedUnit
    ) -> String
}
