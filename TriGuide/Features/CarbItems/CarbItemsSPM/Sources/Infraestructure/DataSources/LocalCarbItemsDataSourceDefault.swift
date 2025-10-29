//
// TriGuide 2025
//

import Foundation

actor LocalCarbItemsDataSourceDefault: LocalCarbItemsDataSource {
    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("carb_items_cache.json")
    }()

    func loadCarbItems() async throws -> [CarbItemDto] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([CarbItemDto].self, from: data)
    }

    func saveCarbItems(_ items: [CarbItemDto]) async throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: fileURL, options: .atomic)
    }

    func addCarbItem(_ item: CarbItemDto) async throws {
        var items = try await loadCarbItems()
        items.append(item)
        try await saveCarbItems(items)
    }

    func removeCarbItem(id: String) async throws {
        var items = try await loadCarbItems()
        items.removeAll { $0.id == id }
        try await saveCarbItems(items)
    }
}
