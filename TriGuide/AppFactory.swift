//
// TriGuide 2026
//

import AthleteProfile
import RaceCalculatorSPM
import RaceNutritionSPM

@MainActor
struct AppFactory {
    // MARK: - Analytics Services

    private let raceNutritionCalculatorAnalytics: RaceNutritionCalculatorAnalyticsService = RaceNutritionCalculatorAnalyticsDefault()

    // MARK: - Coordinators

    func buildRaceNutritionCoordinator() -> RaceNutritionCoordinator {
        let factory = RaceNutritionViewFactoryDefault(
            dependencies: .init(
                raceNutritionCalculatorAnalyticsService: raceNutritionCalculatorAnalytics
            )
        )
        return RaceNutritionCoordinator(factory: factory)
    }

    func buildRaceCalculatorCoordinator() -> RaceCalculatorCoordinator {
        RaceCalculatorViewFactoryDefault(dependencies: .init())
            .buildRaceCalculatorCoordinator()
    }

    func buildAthleteProfileCoordinator() -> AthleteProfileCoordinator {
        AthleteProfileCoordinator()
    }
}
