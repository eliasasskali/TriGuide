//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - AddUserCarbItemUseCase

public protocol AddUserCarbItemUseCase: UseCase {
    func execute(item: CarbItem) async throws
}

// MARK: - AddUserCarbItemUseCaseDefault

public struct AddUserCarbItemUseCaseDefault {
    // MARK: - Dependencies

    let repository: CarbItemsRepository
}

extension AddUserCarbItemUseCaseDefault: AddUserCarbItemUseCase {
    public func execute(item: CarbItem) async throws {
        try await repository.addUserCarbItem(item)
    }
}
