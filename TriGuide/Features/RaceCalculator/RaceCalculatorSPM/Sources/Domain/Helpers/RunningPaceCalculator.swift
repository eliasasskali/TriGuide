//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

public struct RunningPaceCalculator: PaceCalculator {
    public init() {}

    public func calculatePace(
        duration: TimeInterval,
        distance: Double,
        paceUnit: SpeedUnit
    ) -> Double? {
        guard duration > 0, distance > 0 else { return nil }
        let durationInMinutes = duration / 60.0

        switch paceUnit {
        case .minPerKm:
            let distanceInKm = Double(distance) / 1000.0
            let paceSeconds = (durationInMinutes / distanceInKm) * 60
            return paceSeconds

        case .minPerMile:
            let distanceInMiles = Double(distance) / UnitTransformationConstants.metersInMile
            let paceSeconds = (durationInMinutes / distanceInMiles) * 60
            return paceSeconds

        default:
            return nil
        }
    }

    public func calculateTime(pace: Double, distance: Double, paceUnit: SpeedUnit) -> Double? {
        switch paceUnit {
        case .minPerKm:
            let distanceInKm = Double(distance) / 1000.0
            let time = distanceInKm * pace
            return time

        case .minPerMile:
            let distanceInMiles = Double(distance) / UnitTransformationConstants.metersInMile
            let time = distanceInMiles * pace
            return time

        default:
            return nil
        }
    }

    public func calculateDistance(pace: Double, duration: TimeInterval, paceUnit: SpeedUnit) -> Double? {
        switch paceUnit {
        case .minPerKm:
            return (duration / pace) * 1000.0
        case .minPerMile:
            return (duration / pace) * UnitTransformationConstants.metersInMile
        default:
            return nil
        }
    }

    public func formatPace(_ pace: Double, with paceUnit: SpeedUnit) -> String {
        PaceCalculatorHelper.formatPace(paceSeconds: pace, with: paceUnit)
    }
}
