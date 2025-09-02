//
//  SupportedSports.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 1/7/25.
//

import Foundation

// MARK: - Unit transformation constants

enum UnitTransformationConstants {
    static let metersInMile = 1609.34
}

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
            return "Swimming"
        case .bike:
            return "Cycling"
        case .run:
            return "Running"
        case .triathlon:
            return "Triathlon"
        case .duathlon:
            return "Duathlon"
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
}

// MARK: - DistanceUnits

enum DistanceUnit {
    case kilometers
    case miles
    case meters
    case yards

    var factorToMeters: Double {
        switch self {
        case .kilometers: return 1000
        case .miles: return 1609.34
        case .meters: return 1
        case .yards: return 0.9144
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

// MARK: - SupportedUnits

enum SupportedUnit {
    case minPerKm
    case minPerMile
    case kmPerHour
    case milesPerHour
    case minPer100m
    case minPer100yds

    var distanceUnit: DistanceUnit {
        switch self {
        case .minPerKm, .kmPerHour:
            return .kilometers
        case .minPerMile, .milesPerHour:
            return .miles
        case .minPer100m:
            return .meters
        case .minPer100yds:
            return .yards
        }
    }

    var localized: String {
        switch self {
        case .minPerKm:
            return "min/km"
        case .minPerMile:
            return "min/mi"
        case .kmPerHour:
            return "km/h"
        case .milesPerHour:
            return "mph"
        case .minPer100m:
            return "min/100m"
        case .minPer100yds:
            return "min/100yds"
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
        case .supersprint: return "Supersprint"
        case .sprint: return "Sprint"
        case .olympic: return "Olympic"
        case .half: return "Half (70.3)"
        case .full: return "Full (140.6)"
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
    case olympic
    case half
    case full
}

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
    case a3k
    case a5k
    case a10k
    case halfMarathon
    case marathon
    case custom(Double)

    static var allCases: [RunningDistance] {
        [.a1500m, .a3k, .a5k, .a10k, .halfMarathon, .marathon]
    }

    var meters: Double {
        switch self {
        case .a1500m: return 1500
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
        case .a3k: return "3K"
        case .a5k: return "5K"
        case .a10k: return "10K"
        case .halfMarathon: return "Half Marathon"
        case .marathon: return "Marathon"
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
