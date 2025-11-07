//
// TriGuide 2025
//

import Foundation

actor FavoriteCarbItemsDataSourceDefault: FavoriteCarbItemsDataSource {
    static let favDefaultsKey = "favorite_carb_item_ids"

    private let key: String
    private let defaults: UserDefaults
    private var cachedIds: Set<String>

    init(
        key: String = FavoriteCarbItemsDataSourceDefault.favDefaultsKey,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaults = defaults
        self.cachedIds = Set(defaults.stringArray(forKey: key) ?? [])
    }

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
