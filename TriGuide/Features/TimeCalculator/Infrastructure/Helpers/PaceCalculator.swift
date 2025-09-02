//
//  PaceCalculator.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 11/7/25.
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

struct RunningPaceCalculator: PaceCalculator {
    func calculatePace(
        duration: TimeInterval,
        distance: Double,
        paceUnit: SupportedUnit
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

    func calculateTime(pace: Double, distance: Double, paceUnit: SupportedUnit) -> Double? {
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

    func formatPace(_ pace: Double, with paceUnit: SupportedUnit) -> String {
        TriGuide.formatPace(paceSeconds: pace, with: paceUnit)
    }
}

struct CyclingPaceCalculator: PaceCalculator {
    func calculatePace(duration: TimeInterval, distance: Double, paceUnit: SupportedUnit) -> Double? {
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

    func calculateTime(pace: Double, distance: Double, paceUnit: SupportedUnit) -> Double? {
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

    func formatPace(_ pace: Double, with paceUnit: SupportedUnit) -> String {
        String(format: "%.2f %@", pace, paceUnit.localized)
    }
}

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
        TriGuide.formatPace(paceSeconds: pace, with: paceUnit)
    }
}

private func formatPace(paceSeconds: Double, with unit: SupportedUnit) -> String {
    guard paceSeconds > 0 else { return "--" }

    let totalSeconds = Int(paceSeconds.rounded())
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60

    return String(format: "%d:%02d %@", minutes, seconds, unit.localized)
}
