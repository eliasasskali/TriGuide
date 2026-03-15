//
// TriGuide 2026
//

import Foundation

// MARK: - RaceNutritionCalculatorAnalyticsData

public struct RaceNutritionCalculatorAnalyticsData {
    let durationSeconds: Double
    let sport: String
    let carbInputMode: String
    let carbsPerHour: Double
    let estimatedGramsHourWeight: Double?
    let estimatedGramsHourIntensity: String?
    let consumedCaffeineBeforeStart: Bool
    let fastedState: Bool
    let fuelingProfile: String
    let startCarbIntakeAtSeconds: Double
    let ambientTemperature: Double
    let estimatedTotalGrams: Double
}

// MARK: - RaceNutritionCalculatorAnalyticsService

public protocol RaceNutritionCalculatorAnalyticsService {
    func trackScreenView()
    func trackUseTimeCalculatorClick()
    func trackAdvancedOptionsClick()
    func trackResetClick()
    func trackCarbInputModeChange(mode: String)
    func trackCalculateClick()
    func trackCalculateFinished(analyticsData: RaceNutritionCalculatorAnalyticsData)
}
