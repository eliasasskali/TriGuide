//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - LoadCarbItemsUseCase

public protocol LoadUserCarbItemsUseCase: UseCase {
    func execute(forceRefresh: Bool) async throws -> [CarbItem]
}

// MARK: - LoadCarbItemsUseCaseDefault

public struct LoadUserCarbItemsUseCaseDefault {
    // MARK: - Dependencies

    let repository: CarbItemsRepository
}

extension LoadUserCarbItemsUseCaseDefault: LoadUserCarbItemsUseCase {
    public func execute(forceRefresh: Bool = false) async throws -> [CarbItem] {
        try await repository.getUserCarbItems(forceRefresh: forceRefresh)
    }
}
