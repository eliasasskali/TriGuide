//
// TriGuide 2026
//

import TriGuideDomain

// MARK: - FetchStoredFuelingResultsUseCase

public protocol FetchStoredFuelingResultsUseCase: UseCase {
    func execute() async throws -> [FuelingResult]
}

// MARK: - FetchStoredFuelingResultsUseCaseDefault

public struct FetchStoredFuelingResultsUseCaseDefault {
    // MARK: - Dependencies

    let repository: NutritionPlansRepository
}

// MARK: - FetchStoredFuelingResultsUseCase

extension FetchStoredFuelingResultsUseCaseDefault: FetchStoredFuelingResultsUseCase {
    public func execute() async throws -> [FuelingResult] {
        try await repository.fetchNutritionPlans()
    }
}
