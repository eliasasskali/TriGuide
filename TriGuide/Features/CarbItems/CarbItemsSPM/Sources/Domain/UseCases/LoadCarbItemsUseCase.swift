//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - LoadCarbItemsUseCase

public protocol LoadCarbItemsUseCase: UseCase {
    func execute(forceRefresh: Bool) async throws -> [CarbItem]
}

// MARK: - LoadCarbItemsUseCaseDefault

public struct LoadCarbItemsUseCaseDefault {
    let repository: CarbItemsRepository
}

extension LoadCarbItemsUseCaseDefault: LoadCarbItemsUseCase {
    public func execute(forceRefresh: Bool = false) async throws -> [CarbItem] {
        try await repository.getCarbItems(forceRefresh: forceRefresh)
    }
}
