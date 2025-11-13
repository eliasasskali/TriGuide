//
//  TriGuide 2025
//

import Foundation
import Localization

// MARK: - Unit transformation constants

public enum UnitTransformationConstants {
    public static let metersInKm = 1000.0
    public static let metersInMile = 1609.344
    public static let metersInYard = 0.9144
    public static let kCalInGramOfCarbs = 4.0
}

// MARK: - DistanceUnit

public enum DistanceUnit {
    case kilometers
    case miles
    case meters
    case yards

    public var factorToMeters: Double {
        switch self {
        case .kilometers: return UnitTransformationConstants.metersInKm
        case .miles: return UnitTransformationConstants.metersInMile
        case .meters: return 1
        case .yards: return UnitTransformationConstants.metersInYard
        }
    }

    public var localized: String {
        switch self {
        case .kilometers: return Localizables.Units.kmSymbol
        case .miles: return Localizables.Units.miSymbol
        case .meters: return Localizables.Units.mSymbol
        case .yards: return Localizables.Units.ydSymbol
        }
    }
}
