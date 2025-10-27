//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

public protocol PaceCalculator {
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

    func calculateDistance(
        pace: Double,
        duration: TimeInterval,
        paceUnit: SpeedUnit
    ) -> Double?

    func formatPace(
        _ pace: Double,
        with paceUnit: SpeedUnit
    ) -> String
}
