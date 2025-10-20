//
//  TriGuide 2025
//

import Foundation
import Localization

// MARK: - RaceDistance protocol

protocol RaceDistance: Hashable, CaseIterable {
    var meters: Double { get }
    var displayName: String { get }
}

// MARK: - Swimming Distances

enum SwimmingDistance: RaceDistance, CaseIterable {
    case a400m
    case a750m
    case a1500m
    case a1900m
    case a3800m

    static var allCases: [SwimmingDistance] {
        [.a400m, .a750m, .a1500m, .a1900m, .a3800m]
    }

    var meters: Double {
        switch self {
        case .a400m: return 400
        case .a750m: return 750
        case .a1500m: return 1500
        case .a1900m: return 1900
        case .a3800m: return 3800
        }
    }

    var displayName: String {
        switch self {
        case .a400m: return "400 m"
        case .a750m: return "750 m"
        case .a1500m: return "1500 m"
        case .a1900m: return "1900 m"
        case .a3800m: return "3800 m"
        }
    }
}

// MARK: - Running Distances

enum RunningDistance: RaceDistance, Hashable, CaseIterable {
    case a1500m
    case a2500m
    case a3k
    case a5k
    case a10k
    case halfMarathon
    case marathon
    case custom(Double)

    static var allCases: [RunningDistance] {
        [.a1500m, .a2500m, .a3k, .a5k, .a10k, .halfMarathon, .marathon]
    }

    var meters: Double {
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

    var displayName: String {
        switch self {
        case .a1500m: return "1500m"
        case .a2500m: return "2.5K"
        case .a3k: return "3K"
        case .a5k: return "5K"
        case .a10k: return "10K"
        case .halfMarathon: return Localizables.RaceDistance.halfMarathon
        case .marathon: return Localizables.RaceDistance.marathon
        case .custom(let meters): return "\(meters)m"
        }
    }


}

// MARK: - Cycling Distances

enum CyclingDistance: RaceDistance, CaseIterable {
    case a10k
    case a20k
    case a40k
    case a90k
    case a180k
    case custom(Double)

    static var allCases: [CyclingDistance] {
        [.a10k, .a20k, .a40k, .a90k, .a180k]
    }

    var meters: Double {
        switch self {
        case .a10k: return 10000
        case .a20k: return 20000
        case .a40k: return 40000
        case .a90k: return 90000
        case .a180k: return 180000
        case .custom(let meters): return meters
        }
    }

    var displayName: String {
        switch self {
        case .a10k: return "10k"
        case .a20k: return "20k"
        case .a40k: return "40k"
        case .a90k: return "90k"
        case .a180k: return "180k"
        case .custom(let meters): return "\(meters / 1000)k"
        }
    }
}

// MARK: - Triathlon Distances

enum TriathlonDistance: CaseIterable {
    case supersprint
    case sprint
    case olympic
    case half
    case full

    var swimmingDistance: SwimmingDistance {
        return switch self {
        case .supersprint: .a400m
        case .sprint: .a750m
        case .olympic: .a1500m
        case .half: .a1900m
        case .full: .a3800m
        }
    }

    var cyclingDistance: CyclingDistance {
        switch self {
        case .supersprint: .a10k
        case .sprint: .a20k
        case .olympic: .a40k
        case .half: .a90k
        case .full: .a180k
        }
    }

    var runningDistance: RunningDistance {
        switch self {
        case .supersprint: .a3k
        case .sprint: .a5k
        case .olympic: .a10k
        case .half: .halfMarathon
        case .full: .marathon
        }
    }

    var displayName: String {
        switch self {
        case .supersprint: return Localizables.RaceDistance.supersprint
        case .sprint: return Localizables.RaceDistance.sprint
        case .olympic: return Localizables.RaceDistance.triathlonOlympic
        case .half: return Localizables.RaceDistance.triathlonMiddle
        case .full: return Localizables.RaceDistance.triathlonFull
        }
    }

    static var allCases: [TriathlonDistance] {
        [.supersprint, .sprint, .olympic, .half, .full]
    }
}

// MARK: - Duathlon Distances

enum DuathlonDistance: CaseIterable {
    case supersprint
    case sprint
    case standard
    case middle
    case long

    var firstRunDistance: RunningDistance {
        switch self {
        case .supersprint: .a2500m
        case .sprint: .a5k
        case .standard: .a10k
        case .middle: .a10k
        case .long: .a10k
        }
    }

    var cyclingDistance: CyclingDistance {
        switch self {
        case .supersprint: .a10k
        case .sprint: .a20k
        case .standard: .a40k
        case .middle: .custom(60000)
        case .long: .custom(150000)
        }
    }

    var secondRunDistance: RunningDistance {
        switch self {
        case .supersprint: .a2500m
        case .sprint: .a2500m
        case .standard: .a5k
        case .middle: .a10k
        case .long: .custom(30000)
        }
    }

    var displayName: String {
        switch self {
        case .supersprint: return Localizables.RaceDistance.supersprint
        case .sprint: return Localizables.RaceDistance.sprint
        case .standard: return Localizables.RaceDistance.duathlonStandard
        case .middle: return Localizables.RaceDistance.duathlonMiddle
        case .long: return Localizables.RaceDistance.duathlonLong
        }
    }

    static var allCases: [DuathlonDistance] {
        [.supersprint, .sprint, .standard, .middle, .long]
    }
}
