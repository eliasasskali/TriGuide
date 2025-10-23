//
//  TriGuide 2025
//

import Foundation
import Localization

// MARK: - Duathlon Distances

public enum DuathlonDistance: CaseIterable {
    case supersprint
    case sprint
    case standard
    case middle
    case long

    public var firstRunDistance: RunningDistance {
        switch self {
        case .supersprint: .a2500m
        case .sprint: .a5k
        case .standard: .a10k
        case .middle: .a10k
        case .long: .a10k
        }
    }

    public var cyclingDistance: CyclingDistance {
        switch self {
        case .supersprint: .a10k
        case .sprint: .a20k
        case .standard: .a40k
        case .middle: .custom(60000)
        case .long: .custom(150000)
        }
    }

    public var secondRunDistance: RunningDistance {
        switch self {
        case .supersprint: .a2500m
        case .sprint: .a2500m
        case .standard: .a5k
        case .middle: .a10k
        case .long: .custom(30000)
        }
    }

    public var displayName: String {
        switch self {
        case .supersprint: return Localizables.RaceDistance.supersprint
        case .sprint: return Localizables.RaceDistance.sprint
        case .standard: return Localizables.RaceDistance.duathlonStandard
        case .middle: return Localizables.RaceDistance.duathlonMiddle
        case .long: return Localizables.RaceDistance.duathlonLong
        }
    }

    public static var allCases: [DuathlonDistance] {
        [.supersprint, .sprint, .standard, .middle, .long]
    }
}
