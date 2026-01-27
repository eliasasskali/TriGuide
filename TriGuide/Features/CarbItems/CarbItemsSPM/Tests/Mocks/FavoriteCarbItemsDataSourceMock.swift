//
// TriGuide 2025
//

@testable import CarbItemsSPM
import Foundation

final actor FavoriteCarbItemsDataSourceMock: FavoriteCarbItemsDataSource {
    var favoriteIds: Set<String> = []

    func getFavoriteIds() async -> [String] {
        Array(favoriteIds)
    }

    func addFavoriteId(_ id: String) async {
        favoriteIds.insert(id)
    }

    func removeFavoriteId(_ id: String) async {
        favoriteIds.remove(id)
    }

    func isFavorite(_ id: String) async -> Bool {
        favoriteIds.contains(id)
    }
}
