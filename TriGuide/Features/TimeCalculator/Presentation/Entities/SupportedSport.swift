//
//  TriGuide 2025
//

import Foundation
import Localization

// MARK: - SupportedSports

enum SupportedSport: CaseIterable {
    case swim
    case bike
    case run
    case triathlon
    case duathlon

    var localized: String {
        switch self {
        case .swim:
            return Localizables.Sports.swimming
        case .bike:
            return Localizables.Sports.cycling
        case .run:
            return Localizables.Sports.running
        case .triathlon:
            return Localizables.Sports.triathlon
        case .duathlon:
            return Localizables.Sports.duathlon
        }
    }

    var supportedUnits: [SupportedUnit] {
        switch self {
        case .swim:
            return [.minPer100m, .minPer100yds]
        case .bike:
            return [.kmPerHour, .milesPerHour]
        case .run:
            return [.minPerKm, .minPerMile]
        default:
            return []
        }
    }

    var defaultDistanceUnit: DistanceUnit {
        switch self {
        case .swim:
            return .meters
        case .bike:
            return .kilometers
        case .run:
            return .kilometers
        default:
            return .kilometers
        }
    }

    var representativeIcon: String {
        switch self {
        case .swim:
            return "figure.pool.swim"
        case .bike:
            return "bicycle"
        case .run:
            return "figure.run"
        default:
            return "figure.run"
        }
    }
}
