//
// TriGuide 2026
//

import Foundation

// MARK: - RaceNutritionCalculatorAnalyticsData

public struct RaceNutritionCalculatorAnalyticsData {
    public let calculationId: String?
    public let durationSeconds: Double
    public let sport: String
    public let carbInputMode: String
    public let carbsPerHour: Double
    public let estimatedGramsHourWeight: Double?
    public let estimatedGramsHourIntensity: String?
    public let consumedCaffeineBeforeStart: Bool
    public let fastedState: Bool
    public let fuelingProfile: String
    public let startCarbIntakeAtSeconds: Double
    public let ambientTemperature: Double
    public let estimatedTotalGrams: Double
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
