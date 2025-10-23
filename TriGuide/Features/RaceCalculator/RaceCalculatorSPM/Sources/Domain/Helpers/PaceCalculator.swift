//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

protocol PaceCalculator {
    func calculatePace(
        duration: TimeInterval,
        distance: Double,
        paceUnit: SpeedUnit
    ) -> Double?

    func calculateTime(
        pace: Double,
        distance: Double,
        paceUnit: SpeedUnit
    ) -> Double?

    func formatPace(
        _ pace: Double,
        with paceUnit: SpeedUnit
    ) -> String
}
