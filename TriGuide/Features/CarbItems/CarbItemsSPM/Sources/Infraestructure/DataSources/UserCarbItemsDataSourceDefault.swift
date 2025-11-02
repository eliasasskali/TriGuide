//
// TriGuide 2025
//

import Foundation
import StorageKit

actor UserCarbItemsDataSourceDefault: UserCarbItemsDataSource {
    private let storage: LocalStorage<[CarbItemDto]>

    init(storage: LocalStorage<[CarbItemDto]>? = nil) throws {
        if let storage = storage {
            self.storage = storage
        } else {
            self.storage = try LocalStorage<[CarbItemDto]>(
                fileName: "user_carb_items",
                directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            )
        }
    }

    func getCarbItems() async throws -> [CarbItem] {
        do {
            return try await storage.load().map { $0.toDomain() }
        } catch LocalStorageError.fileNotFound {
            return []
        }
    }

    func addCarbItem(_ item: CarbItem) async throws {
        var currentItems = (try? await storage.load()) ?? []
        guard !currentItems.contains(where: { $0.id == item.id }) else { return }
        currentItems.append(item.toDto())
        try await storage.save(currentItems)
    }

    func deleteCarbItem(id: String) async throws {
        var currentItems = try await storage.load()
        currentItems.removeAll { $0.id == id }
        try await storage.save(currentItems)
    }
}
