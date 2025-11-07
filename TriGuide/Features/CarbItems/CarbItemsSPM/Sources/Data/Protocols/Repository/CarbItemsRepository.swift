//
// TriGuide 2025
//

import Foundation

public protocol CarbItemsRepository: Sendable {
    func getCarbItems(forceRefresh: Bool) async throws -> [CarbItem]
    func getUserCarbItems(forceRefresh: Bool) async throws -> [CarbItem]
    func addUserCarbItem(_ item: CarbItem) async throws
    func removeUserCarbItem(with id: String) async throws
    func toggleFavorite(with id: String) async
}
