//
// TriGuide 2025
//

import Foundation

// MARK: - Swimming Distances

public enum SwimmingDistance: RaceDistance, CaseIterable {
    case a400m
    case a750m
    case a1500m
    case a1900m
    case a3800m

    public static var allCases: [SwimmingDistance] {
        [.a400m, .a750m, .a1500m, .a1900m, .a3800m]
    }

    public var meters: Double {
        switch self {
        case .a400m: return 400
        case .a750m: return 750
        case .a1500m: return 1500
        case .a1900m: return 1900
        case .a3800m: return 3800
        }
    }

    public var displayName: String {
        switch self {
        case .a400m: return "400m"
        case .a750m: return "750m"
        case .a1500m: return "1500m"
        case .a1900m: return "1900m"
        case .a3800m: return "3800m"
        }
    }
}
