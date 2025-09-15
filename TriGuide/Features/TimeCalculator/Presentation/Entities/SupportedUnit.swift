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
        return switch self {
        case .minPerKm, .kmPerHour:
                .kilometers
        case .minPerMile, .milesPerHour:
                .miles
        case .minPer100m:
                .meters
        case .minPer100yds:
                .yards
        }
    }
    
    var defaultSplitsDistance: Double {
        return switch self {
        case .minPerKm, .kmPerHour, .minPerMile, .milesPerHour: 1000
        case .minPer100m, .minPer100yds: 100
        }
    }
    
    var localized: String {
        return switch self {
        case .minPerKm:
            Localizables.Units.minPerKmSymbol
        case .minPerMile:
            Localizables.Units.minPerMileSymbol
        case .kmPerHour:
            Localizables.Units.kmhSymbol
        case .milesPerHour:
            Localizables.Units.mphSymbol
        case .minPer100m:
            Localizables.Units.minPer100mSymbol
        case .minPer100yds:
            Localizables.Units.minPer100ydSymbol
        }
    }
}
