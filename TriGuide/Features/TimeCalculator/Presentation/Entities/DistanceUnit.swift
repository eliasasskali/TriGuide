//
//  TriGuide 2025
//

import Foundation

// MARK: - Unit transformation constants

enum UnitTransformationConstants {
    static let metersInKm = 1000.0
    static let metersInMile = 1609.34
    static let metersInYard = 0.9144
}

// MARK: - DistanceUnit

enum DistanceUnit {
    case kilometers
    case miles
    case meters
    case yards

    var factorToMeters: Double {
        switch self {
        case .kilometers: return UnitTransformationConstants.metersInKm
        case .miles: return UnitTransformationConstants.metersInMile
        case .meters: return 1
        case .yards: return UnitTransformationConstants.metersInYard
        }
    }

    var localized: String {
        switch self {
        case .kilometers: return "kms"
        case .miles: return "miles"
        case .meters: return "meters"
        case .yards: return "yds"
        }
    }
}
