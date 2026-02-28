//
// TriGuide 2025
//

import Combine
import Foundation
import Localization
import TriGuideDomain

@MainActor
public class RaceNutritionResultViewModel: ObservableObject {
    // MARK: - Dependencies

    private let saveFuelingPlanUseCase: SaveFuelingPlanUseCase

    // MARK: - Properties

    @Published var errorMessage: String? = nil

    // MARK: - Initializer

    public init(saveFuelingPlanUseCase: SaveFuelingPlanUseCase) {
        self.saveFuelingPlanUseCase = saveFuelingPlanUseCase
    }

    func saveFuelingPlan(
        _ plan: FuelingResult,
        planName: String
    ) async -> Bool {
        do {
            try await saveFuelingPlanUseCase.execute(plan: plan, planName: planName)
            return true
        } catch {
            handle(error)
            return false
        }
    }
}

private extension RaceNutritionResultViewModel {
    func handle(_ error: Error) {
        guard let repositoryError =
            error as? NutritionPlansRepositoryDefault.RepositoryError
        else {
            errorMessage = Localizables.Errors.generic
            return
        }

        switch repositoryError {
        case .duplicateNutritionPlan:
            errorMessage = Localizables.Errors.fuelingPlanDuplicateItem
        case .saveFailed:
            errorMessage = Localizables.Errors.fuelingPlanSaveFailed
        default:
            errorMessage = Localizables.Errors.generic
        }
    }
}
