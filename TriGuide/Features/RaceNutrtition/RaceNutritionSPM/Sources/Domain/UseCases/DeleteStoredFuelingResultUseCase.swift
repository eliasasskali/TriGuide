//
// TriGuide 2026
//

import TriGuideDomain

// MARK: - DeleteStoredFuelingResultUseCase

public protocol DeleteStoredFuelingResultUseCase: UseCase {
    func execute(plan: FuelingResult) async throws
}

// MARK: - DeleteStoredFuelingResultUseCaseDefault

public struct DeleteStoredFuelingResultUseCaseDefault {
    // MARK: - Dependencies

    let repository: NutritionPlansRepository
}

// MARK: - DeleteStoredFuelingResultUseCase

extension DeleteStoredFuelingResultUseCaseDefault: DeleteStoredFuelingResultUseCase {
    public func execute(plan: FuelingResult) async throws {
        try await repository.deleteNutritionPlan(plan)
    }
}
