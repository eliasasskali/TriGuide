//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - SearchCarbItemsUseCase

public protocol SearchCarbItemsUseCase: UseCase {
    func execute(
        carbItems: [CarbItem],
        searchText: String
    ) -> [CarbItem]
}

// MARK: - SearchCarbItemsUseCaseDefault

struct SearchCarbItemsUseCaseDefault: SearchCarbItemsUseCase {
    public func execute(
        carbItems: [CarbItem],
        searchText: String
    ) -> [CarbItem] {
        let query = searchText.lowercased()

        return carbItems.filter { carbItem in
            carbItem.name.lowercased().contains(query) ||
            carbItem.type.rawValue.lowercased().contains(query) ||
            carbItem.brand?.lowercased().contains(query) ?? false
        }
    }
}
