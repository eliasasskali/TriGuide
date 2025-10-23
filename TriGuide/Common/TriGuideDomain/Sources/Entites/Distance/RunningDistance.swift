//
// TriGuide 2025
//

import Foundation
import Localization
import DesignSystem

// MARK: - Running Distances

public enum RunningDistance: RaceDistance, Hashable, CaseIterable {
    case a1500m
    case a2500m
    case a3k
    case a5k
    case a10k
    case halfMarathon
    case marathon
    case custom(Double)

    public static var allCases: [RunningDistance] {
        [.a1500m, .a2500m, .a3k, .a5k, .a10k, .halfMarathon, .marathon]
    }

    public var meters: Double {
        switch self {
        case .a1500m: return 1500
        case .a2500m: return 2500
        case .a3k: return 3000
        case .a5k: return 5000
        case .a10k: return 10000
        case .halfMarathon: return 21097
        case .marathon: return 42195
        case .custom(let meters): return meters
        }
    }

    public var displayName: String {
        switch self {
        case .a1500m: return "1500m"
        case .a2500m: return "2500m"
        case .a3k: return "3K"
        case .a5k: return "5K"
        case .a10k: return "10K"
        case .halfMarathon: return Localizables.RaceDistance.halfMarathon
        case .marathon: return Localizables.RaceDistance.marathon
        case .custom(let meters): return "\((meters / 1000).formattedAsDecimal()) \(Localizables.Units.kmSymbol)"
        }
    }
}
