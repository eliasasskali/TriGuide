//
//  TriGuide 2025
//

import Foundation
import Localization

// MARK: - SupportedSports

public enum SupportedSport: CaseIterable {
    case swim
    case bike
    case run
    case triathlon
    case duathlon

    public static var singleSports: [SupportedSport] {
        return [.swim, .bike, .run]
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

    /// - Parameters:
    ///   - intensity: intensity zone
    ///   - fasted: true if athlete is fasted (reduces carb fraction)
    ///   - duration: session duration in seconds
    ///   - ambientTempC: ambient temperature in °C (heat increases CHO utilisation slightly)
    /// - Returns: fraction (0..1) of energy expected from carbs (physiological / amateur-oriented)
    func ratioOfCarbsUsed(
        for intensity: Intensity,
        fasted: Bool = false,
        duration: TimeInterval = 0,
        ambientTempC: Double = 20.0
    ) -> Double {
        // Start with base (fed)
        var ratio = baseCarbRatio(for: intensity)

        // Fasted reduction (bigger at low/moderate)
        if fasted {
            switch intensity {
            case .low: ratio -= 0.15
            case .moderate: ratio -= 0.10
            case .high: ratio -= 0.05
            }
        }

        // Duration effect:
        // - scale-up from 0 -> 1 h (sessions < 1h use less exogenous CHO)
        // - small downshift after 1h (body shifts slightly towards fat over many hours)
        let hours = duration / 3600.0
        if hours < 1.0 {
            // linear ramp: 0h => 0% of base, 1h => 100% of base
            ratio *= hours
        } else {
            // after first hour: modest reduction up to -0.10 by ~6h
            let durReduction = min(0.10, 0.02 * max(0.0, hours - 1.0)) // 0 at 1h, 0.10 at 6h
            ratio -= durReduction
        }

        // Temperature modifier (very small effect)
        if ambientTempC >= 28.0 {
            ratio += 0.05 // hotter conditions increase CHO reliance
        } else if ambientTempC >= 22.0 {
            ratio += 0.02
        }

        // Sanity-clamp
        ratio = max(0.05, min(ratio, 0.95))
        return ratio
    }

    /// - Parameters:
    ///   - intensity: intensity zone
    ///   - weightKg: athlete body mass (kg)
    ///   - duration: duration in seconds
    ///   - fasted: whether athlete is fasted
    ///   - capped: if true, apply amateur-safe caps (avoids recommending >90 g/h to untrained guts)
    ///   - gutTrained: if true, raise caps (gut-trained athletes can tolerate higher exogenous rates)
    ///   - ambientTempC: ambient temp in °C
    /// - Returns: recommended grams carbohydrate per hour
    func recommendedCarbsPerHour(
        for intensity: Intensity,
        weightKg: Double,
        duration: TimeInterval? = nil, // optional duration
        fasted: Bool = false,
        capped: Bool = true,
        gutTrained: Bool = false,
        ambientTempC: Double = 20.0
    ) -> Double {
        // Determine kcal/hr
        let (lowK, highK) = energyExpenditurePerKgHour(for: intensity)
        let kcalPerKg = (Double(lowK) + Double(highK)) / 2.0
        let kcalPerHour = kcalPerKg * weightKg

        // Determine ratio based on intensity, fed/fasted, optional duration, temp
        let ratio = ratioOfCarbsUsed(
            for: intensity,
            fasted: fasted,
            duration: duration ?? 3600,
            ambientTempC: ambientTempC
        )
        let gramsPerHour = (kcalPerHour * ratio) / UnitTransformationConstants.kCalInGramOfCarbs

        // Amateur-friendly caps
        let capMultiplier = gutTrained ? 1.4 : 1.0
        let cap = intensity.amateurGramsPerHourCap * capMultiplier

        var recommended = gramsPerHour
        if capped {
            if intensity == .low { recommended *= 1.10 } // boost low intensity
            if intensity == .moderate { recommended *= 1.05 } // mild boost
            recommended = min(recommended, cap)
        }

        // Duration-based scaling for short sessions (<1h) only if a duration was provided
        if let actualDuration = duration {
            let hours = actualDuration / 3600.0
            if hours < 1.0 {
                recommended *= max(0.0, hours)
            }
        }

        // Final safety clamp
        recommended = max(0.0, recommended)
        return recommended.rounded(.down)
    }
}

// MARK: - Private Helpers

private extension SupportedSport {
    private func baseCarbRatio(for intensity: Intensity) -> Double {
        switch (self, intensity) {
        case (.run, .low): return 0.55
        case (.run, .moderate): return 0.65
        case (.run, .high): return 0.75
        case (.bike, .low): return 0.50
        case (.bike, .moderate): return 0.60
        case (.bike, .high): return 0.70
        case (.swim, .low): return 0.50
        case (.swim, .moderate): return 0.60
        case (.swim, .high): return 0.75
        default: return 0.0
        }
    }
}
