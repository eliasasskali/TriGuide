//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - DeleteUserCarbItemUseCase

public protocol DeleteUserCarbItemUseCase: UseCase {
    func execute(item: CarbItem) async throws
}

// MARK: - DeleteUserCarbItemUseCaseDefault

public struct DeleteUserCarbItemUseCaseDefault {
    let repository: CarbItemsRepository
}

extension DeleteUserCarbItemUseCaseDefault: DeleteUserCarbItemUseCase {
    public func execute(item: CarbItem) async throws {
        try await repository.removeUserCarbItem(with: item.id)
    }
}
