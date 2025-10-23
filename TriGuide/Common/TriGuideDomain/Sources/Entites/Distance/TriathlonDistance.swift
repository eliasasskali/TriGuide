//
//  TriGuide 2025
//

import Foundation
import Localization

// MARK: - Triathlon Distances

public enum TriathlonDistance: CaseIterable {
    case supersprint
    case sprint
    case olympic
    case half
    case full

    public var swimmingDistance: SwimmingDistance {
        return switch self {
        case .supersprint: .a400m
        case .sprint: .a750m
        case .olympic: .a1500m
        case .half: .a1900m
        case .full: .a3800m
        }
    }

    public var cyclingDistance: CyclingDistance {
        switch self {
        case .supersprint: .a10k
        case .sprint: .a20k
        case .olympic: .a40k
        case .half: .a90k
        case .full: .a180k
        }
    }

    public var runningDistance: RunningDistance {
        switch self {
        case .supersprint: .a3k
        case .sprint: .a5k
        case .olympic: .a10k
        case .half: .halfMarathon
        case .full: .marathon
        }
    }

    public var displayName: String {
        switch self {
        case .supersprint: return Localizables.RaceDistance.supersprint
        case .sprint: return Localizables.RaceDistance.sprint
        case .olympic: return Localizables.RaceDistance.triathlonOlympic
        case .half: return Localizables.RaceDistance.triathlonMiddle
        case .full: return Localizables.RaceDistance.triathlonFull
        }
    }

    public static var allCases: [TriathlonDistance] {
        [.supersprint, .sprint, .olympic, .half, .full]
    }
}
