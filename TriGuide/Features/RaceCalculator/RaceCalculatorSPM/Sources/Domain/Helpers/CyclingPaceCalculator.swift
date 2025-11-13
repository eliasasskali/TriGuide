//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

public struct CyclingPaceCalculator: PaceCalculator {
    
    public init() {}

    public func calculatePace(duration: TimeInterval, distance: Double, paceUnit: SpeedUnit) -> Double? {
        guard duration > 0, distance > 0 else { return nil }
        let durationInHours = duration / 3600.0

        switch paceUnit {
        case .kmPerHour:
            let distanceInKm = Double(distance / 1000)
            return distanceInKm / durationInHours

        case .milesPerHour:
            let distanceInMiles = Double(distance) / UnitTransformationConstants.metersInMile
            return Double(distanceInMiles) / durationInHours

        default:
            return nil
        }
    }

    public func calculateTime(pace: Double, distance: Double, paceUnit: SpeedUnit) -> Double? {
        guard pace > 0, distance > 0 else { return nil }

        switch paceUnit {
        case .kmPerHour:
            let distanceInKm = distance / 1000
            let durationInHours = distanceInKm / pace
            return durationInHours * 3600
        case .milesPerHour:
            let distanceInMiles = distance / UnitTransformationConstants.metersInMile
            let durationInHours = distanceInMiles / pace
            return durationInHours * 3600
        default:
            return nil
        }
    }

    public func calculateDistance(pace: Double, duration: TimeInterval, paceUnit: SpeedUnit) -> Double? {
        guard pace > 0, duration > 0 else { return nil }

        switch paceUnit {
        case .kmPerHour:
            return (pace * (duration / 3600.0)) * 1000
        case .milesPerHour:
            return (pace * (duration / 3600.0)) * UnitTransformationConstants.metersInMile
        default:
            return nil
        }
    }

    public func formatPace(_ pace: Double, with paceUnit: SpeedUnit) -> String {
        "\(pace.formattedAsDecimal(maxFractionDigits: 2)) \(paceUnit.localized)"
    }
}
