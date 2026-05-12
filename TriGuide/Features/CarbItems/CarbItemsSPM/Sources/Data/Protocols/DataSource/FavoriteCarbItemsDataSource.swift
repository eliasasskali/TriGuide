//
// TriGuide 2025
//

import Foundation

public protocol FavoriteCarbItemsDataSource: Sendable {
    func getFavoriteIds() async -> [String]
    func addFavoriteId(_ id: String) async
    func removeFavoriteId(_ id: String) async
    func isFavorite(_ id: String) async -> Bool
}
