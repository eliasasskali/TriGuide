//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

struct SwimmingPaceCalculator: PaceCalculator {
    func calculatePace(duration: TimeInterval, distance: Double, paceUnit: SpeedUnit) -> Double? {
        guard duration > 0, distance > 0 else { return nil }

        let distanceInUnit: Double
        switch paceUnit {
        case .minPer100m:
            distanceInUnit = distance
        case .minPer100yds:
            distanceInUnit = distance / 0.9144
        default:
            return nil
        }

        return (duration / distanceInUnit) * 100
    }

    func calculateTime(pace: Double, distance: Double, paceUnit: SpeedUnit) -> Double? {
        let distanceInUnit: Double
        switch paceUnit {
        case .minPer100m:
            distanceInUnit = distance
        case .minPer100yds:
            distanceInUnit = distance / 0.9144
        default:
            return nil
        }

        return (pace / 100) * distanceInUnit
    }

    func calculateDistance(pace: Double, duration: TimeInterval, paceUnit: SpeedUnit) -> Double? {
        switch paceUnit {
        case .minPer100m:
            return (duration / pace ) * 100
        case .minPer100yds:
            return (duration / pace ) * UnitTransformationConstants.metersInYard
        default:
            return nil
        }
    }

    func formatPace(_ pace: Double, with paceUnit: SpeedUnit) -> String {
        PaceCalculatorHelper.formatPace(paceSeconds: pace, with: paceUnit)
    }
}
