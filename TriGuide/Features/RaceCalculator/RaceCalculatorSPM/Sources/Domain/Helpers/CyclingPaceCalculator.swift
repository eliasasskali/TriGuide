//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

struct CyclingPaceCalculator: PaceCalculator {
    func calculatePace(duration: TimeInterval, distance: Double, paceUnit: SpeedUnit) -> Double? {
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

    func calculateTime(pace: Double, distance: Double, paceUnit: SpeedUnit) -> Double? {
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

    func formatPace(_ pace: Double, with paceUnit: SpeedUnit) -> String {
        "\(pace.formattedAsDecimal(maxFractionDigits: 2)) \(paceUnit.localized)"
    }
}
