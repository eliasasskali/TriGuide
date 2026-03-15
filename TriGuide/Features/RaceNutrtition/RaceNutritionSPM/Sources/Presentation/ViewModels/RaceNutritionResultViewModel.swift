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
    private let deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCase
    private let replaceFuelingPlanUseCase: ReplaceFuelingPlanUseCase

    // MARK: - Properties

    @Published var errorMessage: String? = nil

    // MARK: - Initializer

    public init(
        saveFuelingPlanUseCase: SaveFuelingPlanUseCase,
        deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCase,
        replaceFuelingPlanUseCase: ReplaceFuelingPlanUseCase
    ) {
        self.saveFuelingPlanUseCase = saveFuelingPlanUseCase
        self.deleteStoredFuelingResultUseCase = deleteStoredFuelingResultUseCase
        self.replaceFuelingPlanUseCase = replaceFuelingPlanUseCase
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

    func replaceFuelingPlan(
        oldPlan: FuelingResult,
        updatedPlan: FuelingResult
    ) async -> Bool {
        let updatedTrimmed = updatedPlan.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName: String
        if let name = updatedTrimmed, !name.isEmpty {
            finalName = name
        } else if let name = oldPlan.name, !name.isEmpty {
            finalName = name
        } else {
            finalName = Localizables.RaceNutritionResults.storedPlansItemUnnamedPlan
        }

        do {
            try await replaceFuelingPlanUseCase.execute(
                oldPlan: oldPlan,
                updatedPlan: updatedPlan,
                planName: finalName
            )
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
