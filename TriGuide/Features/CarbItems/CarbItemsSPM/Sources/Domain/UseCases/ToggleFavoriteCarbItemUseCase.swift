//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public protocol ToggleFavoriteCarbItemUseCase: UseCase {
    func execute(id: String) async
}

// MARK: - ToggleFavoriteCarbItemUseCaseDefault

public struct ToggleFavoriteCarbItemUseCaseDefault {
    let repository: CarbItemsRepository
}

extension ToggleFavoriteCarbItemUseCaseDefault: ToggleFavoriteCarbItemUseCase {
    public func execute(id: String) async {
        await repository.toggleFavorite(with: id)
    }
}
