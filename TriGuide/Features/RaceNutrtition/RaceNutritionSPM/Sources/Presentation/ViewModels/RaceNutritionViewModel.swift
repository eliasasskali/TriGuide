//
// TriGuide 2025
//

import Combine
import Foundation
import TriGuideDomain

@MainActor
public class RaceNutritionViewModel: ObservableObject {
    // MARK: - Dependencies

    private let calculateFuelingResultUseCase: CalculateFuelingResultUseCase

    // MARK: - Properties

    @Published var sport: SupportedSport? = .bike
    @Published var duration: TimeInterval?
    @Published var weight: Double?
    @Published var intensity: Intensity? = .moderate
    @Published var hasConsumedCaffeineBefore: Bool = false
    @Published var startEatingAt: TimeInterval = 900.0
    @Published var fasted: Bool = false
    @Published var fuelingProfile: FuelingProfile = .amateur
    @Published var ambientTempC: Double = 20.0

    @Published var isLoading: Bool = false
    @Published var gramsPerHour: Double?
    @Published var estimatedTotalGrams: Double?
    @Published var didFinishCalculation = false

    @Published var fuelingResult: FuelingResult?
    @Published var calculationId: String?

    // MARK: - Computed properties

    var isButtonDisabled: Bool {
        duration == nil || duration == 0 || gramsPerHour == nil || gramsPerHour == 0 || sport == nil
    }

    // MARK: - Initializer

    public init(calculateFuelingResultUseCase: CalculateFuelingResultUseCase) {
        self.calculateFuelingResultUseCase = calculateFuelingResultUseCase

        // On change of any input, recalculate gramsPerHour
        Publishers.CombineLatest4($sport, $duration, $weight, $intensity)
            .combineLatest(Publishers.CombineLatest3($fasted, $fuelingProfile, $ambientTempC))
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [weak self] first, second -> Double? in
                let (sport, duration, weight, intensity) = first
                let (fasted, fuelingProfile, ambientTempC) = second
                guard let self, weight != nil, sport != nil, intensity != nil else { return nil }
                return self.calculateEstimatedTotalGrams(
                    sport: sport,
                    duration: duration,
                    weight: weight,
                    intensity: intensity,
                    fasted: fasted,
                    fuelingProfile: fuelingProfile,
                    ambientTempC: ambientTempC
                )
            }
            .assign(to: &$gramsPerHour)
    }

    // MARK: - Calculation methods

    /// Calculates the total grams of carbohydrates needed based on duration and grams per hour.
    func calculateTotalGrams() {
        isLoading = true
        defer { isLoading = false }
        guard let duration, duration > 0, let gramsPerHour else { return }

        estimatedTotalGrams = ((duration / 3600) * gramsPerHour).rounded(.down)
        calculationId = UUID().uuidString
        didFinishCalculation = true
    }

    /// Calculates the fueling result on a background queue to avoid blocking UI.
    func calculateFuelingAsync(from selection: [CarbItemSelection]) async -> FuelingResult? {
        guard let estimatedTotalGrams, let duration, let sport else { return nil }

        isLoading = true
        defer { isLoading = false }

        let fuelingInput = FuelingInput(
            carbItemSelection: selection,
            carbsTarget: estimatedTotalGrams,
            duration: duration,
            sport: sport,
            startBuffer: startEatingAt,
            hasConsumedCaffeineBefore: hasConsumedCaffeineBefore
        )

        let useCase = calculateFuelingResultUseCase
        let result = await Task.detached(priority: .userInitiated) {
            useCase.execute(fuelingInput: fuelingInput)
        }.value

        fuelingResult = result
        return result
    }

    func reset() {
        sport = .bike
        duration = nil
        weight = nil
        intensity = .moderate
        hasConsumedCaffeineBefore = false
        startEatingAt = 900.0
        fasted = false
        fuelingProfile = .amateur
        ambientTempC = 20.0
        gramsPerHour = nil
        estimatedTotalGrams = nil
        didFinishCalculation = false
        fuelingResult = nil
        calculationId = nil
    }
}

// MARK: - Private methods

private extension RaceNutritionViewModel {
    func calculateEstimatedTotalGrams(
        sport: SupportedSport?,
        duration: TimeInterval?,
        weight: Double?,
        intensity: Intensity?,
        fasted: Bool,
        fuelingProfile: FuelingProfile,
        ambientTempC: Double
    ) -> Double? {
        guard let weight, let sport, let intensity else { return nil }

        return sport.recommendedCarbsPerHour(
            for: intensity,
            weightKg: weight,
            duration: duration,
            fasted: fasted,
            fuelingProfile: fuelingProfile,
            ambientTempC: ambientTempC
        )
    }
}
