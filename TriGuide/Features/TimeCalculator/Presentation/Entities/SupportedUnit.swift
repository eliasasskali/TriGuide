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
            return Localizables.Units.minPerKmSymbol
        case .minPerMile:
            return Localizables.Units.minPerMileSymbol
        case .kmPerHour:
            return Localizables.Units.kmhSymbol
        case .milesPerHour:
            return Localizables.Units.mphSymbol
        case .minPer100m:
            return Localizables.Units.minPer100mSymbol
        case .minPer100yds:
            return Localizables.Units.minPer100ydSymbol
        }
    }
}
