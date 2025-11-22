//
// TriGuide 2025
//

import Combine
import Foundation
import TriGuideDomain

@MainActor
public class RaceNutritionViewModel: ObservableObject {
    @Published var sport: SupportedSport?
    @Published var duration: TimeInterval?
    @Published var weight: Double?
    @Published var intensity: Intensity?
    @Published var fasted: Bool = false
    @Published var capped: Bool = true
    @Published var gutTrained: Bool = false
    @Published var ambientTempC: Double = 20.0

    @Published var isLoading: Bool = false
    @Published var gramsPerHour: Double?
    @Published var estimatedTotalGrams: Double?
    @Published var didFinishCalculation = false

    @Published var fuelingResult: FuelingResult?

    let calculateFuelingResultUseCase: CalculateFuelingResultUseCase

    var isButtonDisabled: Bool {
        duration == nil || duration == 0 || gramsPerHour == nil || sport == nil
    }

    public init(calculateFuelingResultUseCase: CalculateFuelingResultUseCase) {
        self.calculateFuelingResultUseCase = calculateFuelingResultUseCase

        // On change of any input, recalculate gramsPerHour
        Publishers.CombineLatest4($sport, $duration, $weight, $intensity)
            .combineLatest(Publishers.CombineLatest4($fasted, $capped, $gutTrained, $ambientTempC))
            .map { [weak self] first, second in
                let (sport, duration, weight, intensity) = first
                let (fasted, capped, gutTrained, ambientTempC) = second
                return self?.calculateEstimatedTotalGrams(
                    sport: sport,
                    duration: duration,
                    weight: weight,
                    intensity: intensity,
                    fasted: fasted,
                    capped: capped,
                    gutTrained: gutTrained,
                    ambientTempC: ambientTempC
                )
            }
            .assign(to: &$gramsPerHour)
    }


    func calculateTotalGrams() {
        isLoading = true
        defer { isLoading = false }
        guard let duration, duration > 0, let gramsPerHour else { return }

        estimatedTotalGrams = ((duration / 3600) * gramsPerHour).rounded(.down)
        didFinishCalculation = true
    }

    // MARK: - Final result calculation

    func calculateFueling(from selection: [CarbItemSelection]) -> FuelingResult? {
        guard let estimatedTotalGrams, let duration, let sport else { return nil }
        let fuelingInput = FuelingInput(
            carbItemSelection: selection,
            carbsTarget: estimatedTotalGrams,
            duration: duration,
            sport: sport
        )
        return calculateFuelingResultUseCase.execute(fuelingInput: fuelingInput)
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
        capped: Bool,
        gutTrained: Bool,
        ambientTempC: Double
    ) -> Double? {
        guard let weight, let sport, let intensity else { return nil }

        return sport.recommendedCarbsPerHour(
            for: intensity,
            weightKg: weight,
            duration: duration,
            fasted: fasted,
            capped: capped,
            gutTrained: gutTrained,
            ambientTempC: ambientTempC
        )
    }
}
