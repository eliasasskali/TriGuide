//
//  TriGuide 2025
//

import Foundation
import Localization

// MARK: - SupportedSports

public enum SupportedSport: CaseIterable, Sendable {
    case swim
    case bike
    case run
    case triathlon
    case duathlon

    public static var nutritionSupportedSports: [SupportedSport] {
        return [.bike, .run]
    }

    public var localized: String {
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

    public var supportedUnits: [SpeedUnit] {
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

    public var defaultDistanceUnit: DistanceUnit {
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

    public var representativeIcon: String {
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

// MARK: - Sport Energy Expenditure and Fuel Utilization

public extension SupportedSport {
    func energyExpenditurePerKgHour(for intensity: Intensity) -> (Int, Int) {
        switch (self, intensity) {
        case (.run, .low): return (7, 8)
        case (.run, .moderate): return (9, 10)
        case (.run, .high): return (11, 12)
        case (.bike, .low): return (5, 6)
        case (.bike, .moderate): return (7, 8)
        case (.bike, .high): return (9, 10)
        case (.swim, .low): return (6, 7)
        case (.swim, .moderate): return (8, 9)
        case (.swim, .high): return (10, 11)
        default: return (0, 0)
        }
    }

    /// Returns the fraction of energy expected from carbs (metabolic truth, sport-agnostic).
    /// NOTE: This reflects what the body *burns*, not what an athlete can *ingest*.
    /// Sport-specific GI tolerance is applied separately in recommendedCarbsPerHour.
    func ratioOfCarbsUsed(
        for intensity: Intensity,
        fasted: Bool = false,
        ambientTempC: Double = 20.0
    ) -> Double {
        var ratio = baseCarbRatio(for: intensity)

        if fasted {
            switch intensity {
            case .low: ratio -= 0.15
            case .moderate: ratio -= 0.10
            case .high: ratio -= 0.05
            }
        }

        // Temperature modifier
        if ambientTempC >= 28.0 {
            ratio += 0.05
        } else if ambientTempC >= 22.0 {
            ratio += 0.02
        }

        return max(0.05, min(ratio, 0.95))
    }

    func recommendedCarbsPerHour(
        for intensity: Intensity,
        weightKg: Double,
        duration: TimeInterval? = nil,
        fasted: Bool = false,
        fuelingProfile: FuelingProfile = .amateur,
        ambientTempC: Double = 20.0
    ) -> Double {
        guard let duration else { return 0 }
        let hours = duration / 3600.0

        // Metabolic carb burn (what the body uses, sport-independent)
        let (lowK, highK) = energyExpenditurePerKgHour(for: intensity)
        let kcalPerKg = (Double(lowK) + Double(highK)) / 2.0
        let kcalPerHour = kcalPerKg * weightKg

        let metabolicRatio = ratioOfCarbsUsed(
            for: intensity,
            fasted: fasted,
            ambientTempC: ambientTempC
        )
        let metabolicGramsPerHour = (kcalPerHour * metabolicRatio) / UnitTransformationConstants.kCalInGramOfCarbs

        // Sport specific GI intake tolerance factor.
        // Running: mechanical impact causes gastric jostling → lower absorption.
        // Cycling: seated, no impact → best GI tolerance.
        var gramsPerHour = metabolicGramsPerHour * giIntakeFactor()

        // Duration ramp - linear from 30min to 1.5h.
        // Short efforts don't warrant the same intake as longer ones.
        let rampFloor = 0.5
        let rampCeiling = 1.5
        if hours < rampCeiling {
            let rampProgress = (hours - rampFloor) / (rampCeiling - rampFloor)
            gramsPerHour *= max(0, min(1, rampProgress))
        }

        // Long-duration downshift.
        // Past 2h the body shifts slightly toward fat oxidation.
        if hours > 2.0 {
            let durReduction = min(0.10, 0.02 * (hours - 2.0))
            gramsPerHour *= (1.0 - durReduction)
        }

        // Intensity micro adjustments (always applied)
        if intensity == .low { gramsPerHour *= 1.10 }
        if intensity == .moderate { gramsPerHour *= 1.05 }

        // Apply fueling profile caps
        switch fuelingProfile {
        case .amateur:
            gramsPerHour = min(gramsPerHour, sportSpecificCap(for: intensity))
        case .trained:
            gramsPerHour = min(gramsPerHour, sportSpecificCap(for: intensity) * 1.4)
        case .uncapped:
            break
        }

        let result = max(0, gramsPerHour).rounded(.down)

        // Below 15 g/h the intake is negligible — glycogen covers the effort.
        return result >= 15 ? result : 0
    }
}

// MARK: - Private Helpers

private extension SupportedSport {
    /// Metabolic carb burn fraction. Running burns more carbs per kg, hence slightly
    /// higher ratios, but this reflects combustion, not what the athlete should eat.
    func baseCarbRatio(for intensity: Intensity) -> Double {
        switch (self, intensity) {
        case (.run, .low): return 0.50
        case (.run, .moderate): return 0.60
        case (.run, .high): return 0.72
        case (.bike, .low): return 0.50
        case (.bike, .moderate): return 0.60
        case (.bike, .high): return 0.70
        case (.swim, .low): return 0.50
        case (.swim, .moderate): return 0.60
        case (.swim, .high): return 0.75
        default: return 0.0
        }
    }

    /// GI tolerance factor: scales metabolic carb burn down to what can realistically
    /// be ingested and absorbed, per sport. Running is the most restrictive due to
    /// repetitive impact stress on the gut.
    func giIntakeFactor() -> Double {
        switch self {
        case .run: return 0.55
        case .bike: return 1.0
        case .swim: return 0.65
        default: return 1.0
        }
    }

    /// Sport specific hard caps on grams/hr for amateur athletes.
    /// Running caps are lower than cycling due to GI stress.
    func sportSpecificCap(for intensity: Intensity) -> Double {
        switch (self, intensity) {
        case (.run, .low): return 30
        case (.run, .moderate): return 50
        case (.run, .high): return 70
        case (.bike, .low): return 50
        case (.bike, .moderate): return 70
        case (.bike, .high): return 90
        case (.swim, .low): return 35
        case (.swim, .moderate): return 55
        case (.swim, .high): return 75
        default: return 60
        }
    }
}
