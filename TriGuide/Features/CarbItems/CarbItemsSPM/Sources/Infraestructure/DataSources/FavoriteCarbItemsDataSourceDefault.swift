//
// TriGuide 2025
//

import Foundation

actor FavoriteCarbItemsDataSourceDefault: FavoriteCarbItemsDataSource {
    // MARK: - Constants

    static let favDefaultsKey = "favorite_carb_item_ids"

    // MARK: - Dependencies

    private let key: String
    private let defaults: UserDefaults
    private var cachedIds: Set<String>

    // MARK: - Initializer

    init(
        key: String = FavoriteCarbItemsDataSourceDefault.favDefaultsKey,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaults = defaults
        cachedIds = Set(defaults.stringArray(forKey: key) ?? [])
    }

    // MARK: - FavoriteCarbItemsDataSource

    func getFavoriteIds() async -> [String] {
        Array(cachedIds)
    }

    func addFavoriteId(_ id: String) async {
        guard !cachedIds.contains(id) else { return }
        cachedIds.insert(id)
        defaults.set(Array(cachedIds), forKey: key)
    }

    func removeFavoriteId(_ id: String) async {
        guard cachedIds.contains(id) else { return }
        cachedIds.remove(id)
        defaults.set(Array(cachedIds), forKey: key)
    }

    func isFavorite(_ id: String) async -> Bool {
        cachedIds.contains(id)
    }
}
