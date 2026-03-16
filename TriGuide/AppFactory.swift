//
// TriGuide 2026
//

import AthleteProfile
import CarbItemsSPM
import RaceCalculatorSPM
import RaceNutritionSPM

@MainActor
struct AppFactory {
    // MARK: - Analytics Services

    private let raceNutritionCalculatorAnalytics: RaceNutritionCalculatorAnalyticsService = RaceNutritionCalculatorAnalyticsDefault()
    private let carbItemsAnalyticsRaceNutrition: CarbItemsAnalyticsService = CarbItemsAnalyticsDefault(originScreen: .raceNutritionCalculator)
    private let carbItemsAnalyticsUserProfile: CarbItemsAnalyticsService = CarbItemsAnalyticsDefault(originScreen: .userProfile)

    // MARK: - Coordinators

    func buildRaceNutritionCoordinator() -> RaceNutritionCoordinator {
        let factory = RaceNutritionViewFactoryDefault(
            dependencies: .init(
                raceNutritionCalculatorAnalyticsService: raceNutritionCalculatorAnalytics,
                carbItemsAnalyticsService: carbItemsAnalyticsRaceNutrition
            )
        )
        return RaceNutritionCoordinator(factory: factory)
    }

    func buildRaceCalculatorCoordinator() -> RaceCalculatorCoordinator {
        RaceCalculatorViewFactoryDefault(dependencies: .init())
            .buildRaceCalculatorCoordinator()
    }

    func buildAthleteProfileCoordinator() -> AthleteProfileCoordinator {
        AthleteProfileCoordinator(carbItemsAnalyticsService: carbItemsAnalyticsUserProfile)
    }
}
