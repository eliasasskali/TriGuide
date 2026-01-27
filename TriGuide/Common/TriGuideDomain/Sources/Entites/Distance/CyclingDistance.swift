//
//  TriGuide 2025
//

import DesignSystem
import Foundation
import Localization

// MARK: - Cycling Distances

public enum CyclingDistance: RaceDistance, CaseIterable {
    case a10k
    case a20k
    case a40k
    case a90k
    case a180k
    case custom(Double)

    public static var allCases: [CyclingDistance] {
        [.a10k, .a20k, .a40k, .a90k, .a180k]
    }

    public var meters: Double {
        switch self {
        case .a10k: return 10000
        case .a20k: return 20000
        case .a40k: return 40000
        case .a90k: return 90000
        case .a180k: return 180_000
        case let .custom(meters): return meters
        }
    }

    public var displayName: String {
        return "\((meters / 1000).formattedAsDecimal()) \(Localizables.Units.kmSymbol)"
    }
}
