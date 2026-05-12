//
// TriGuide 2026
//

import TriGuideDomain

// MARK: - ReplaceFuelingPlanUseCase

public protocol ReplaceFuelingPlanUseCase: UseCase {
    func execute(oldPlan: FuelingResult, updatedPlan: FuelingResult, planName: String) async throws
}

// MARK: - ReplaceFuelingPlanUseCaseDefault

public struct ReplaceFuelingPlanUseCaseDefault {
    // MARK: - Dependencies

    let repository: NutritionPlansRepository
}

// MARK: - ReplaceFuelingPlanUseCase

extension ReplaceFuelingPlanUseCaseDefault: ReplaceFuelingPlanUseCase {
    public func execute(oldPlan: FuelingResult, updatedPlan: FuelingResult, planName: String) async throws {
        try await repository.replaceNutritionPlan(oldPlan, with: updatedPlan, name: planName)
    }
}
