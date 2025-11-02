//
// TriGuide 2025
//

import Foundation
import StorageKit

actor CachedCarbItemsDataSourceDefault: CachedCarbItemsDataSource {
    private let storage: LocalStorage<[CarbItemDto]>

    init(storage: LocalStorage<[CarbItemDto]>? = nil) throws {
        if let storage {
            self.storage = storage
        } else {
            self.storage = try LocalStorage<[CarbItemDto]>(
                fileName: "carb_items_cache",
                directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            )
        }
    }

    func loadCarbItems() async throws -> [CarbItemDto] {
        do {
            return try await storage.load()
        } catch LocalStorageError.fileNotFound {
            return []
        }
    }

    func saveCarbItems(_ items: [CarbItemDto]) async throws {
        try await storage.save(items)
    }
}
