//
// TriGuide 2026
//

import TriGuideDomain

// MARK: - SaveFuelinPlanUseCase

public protocol SaveFuelingPlanUseCase: UseCase {
    func execute(plan: FuelingResult, planName: String) async throws
}

// MARK: - SaveFuelingPlanUseCaseDefault

public struct SaveFuelingPlanUseCaseDefault {
    // MARK: - Dependencies

    let repository: NutritionPlansRepository
}

// MARK: - CalculateFuelingResultUseCase

extension SaveFuelingPlanUseCaseDefault: SaveFuelingPlanUseCase {
    public func execute(plan: FuelingResult, planName: String) async throws {
        try await repository.addNutritionPlan(plan, name: planName)
    }
}
