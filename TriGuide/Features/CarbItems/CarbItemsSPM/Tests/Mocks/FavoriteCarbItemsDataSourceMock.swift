//
// TriGuide 2025
//

import Foundation
@testable import CarbItemsSPM

final actor FavoriteCarbItemsDataSourceMock: FavoriteCarbItemsDataSource {
    var favoriteIds: Set<String> = []
    var isFavorite: Bool = false

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
