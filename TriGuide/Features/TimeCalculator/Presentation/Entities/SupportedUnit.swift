//
//  TriGuide 2025
//

import Foundation

// MARK: - SupportedUnits

enum SupportedUnit {
    case minPerKm
    case minPerMile
    case kmPerHour
    case milesPerHour
    case minPer100m
    case minPer100yds

    var distanceUnit: DistanceUnit {
        switch self {
        case .minPerKm, .kmPerHour:
            return .kilometers
        case .minPerMile, .milesPerHour:
            return .miles
        case .minPer100m:
            return .meters
        case .minPer100yds:
            return .yards
        }
    }

    var localized: String {
        switch self {
        case .minPerKm:
            return "min/km"
        case .minPerMile:
            return "min/mi"
        case .kmPerHour:
            return "km/h"
        case .milesPerHour:
            return "mph"
        case .minPer100m:
            return "min/100m"
        case .minPer100yds:
            return "min/100yds"
        }
    }
}
