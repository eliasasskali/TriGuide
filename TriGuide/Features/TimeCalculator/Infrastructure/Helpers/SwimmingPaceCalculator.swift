//
//  TriGuide 2025
//

import Foundation

struct SwimmingPaceCalculator: PaceCalculator {
    func calculatePace(duration: TimeInterval, distance: Double, paceUnit: SupportedUnit) -> Double? {
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

        func calculateTime(pace: Double, distance: Double, paceUnit: SupportedUnit) -> Double? {
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

    func formatPace(_ pace: Double, with paceUnit: SupportedUnit) -> String {
        PaceCalculatorHelper.formatPace(paceSeconds: pace, with: paceUnit)
    }
}
