//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - LoadCarbItemsUseCase

public struct LoadCarbItemsUseCase: UseCase {
    let repository: CarbItemsRepository
}

extension LoadCarbItemsUseCase {
    func execute(forceRefresh: Bool = false) async throws -> [CarbItem] {
        try await repository.getCarbItems(forceRefresh: forceRefresh)
    }
}
