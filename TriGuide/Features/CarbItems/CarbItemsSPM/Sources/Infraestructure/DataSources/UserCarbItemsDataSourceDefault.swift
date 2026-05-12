//
// TriGuide 2025
//

import Foundation
import StorageKit
import TriGuideDomain

actor UserCarbItemsDataSourceDefault: UserCarbItemsDataSource {
    // MARK: - Dependencies

    private let storage: LocalStorage<[CarbItemDto]>

    // MARK: - Initializer

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

    // MARK: - UserCarbItemsDataSource

    func getCarbItems() async throws -> [CarbItem] {
        do {
            return try await storage.load().map { dto in
                CarbItem(
                    id: dto.id,
                    name: dto.name,
                    gramsOfCarbs: dto.gramsOfCarbs,
                    caffeine: dto.caffeine,
                    sodium: dto.sodium,
                    waterVolumeML: dto.waterVolumeML,
                    type: dto.type,
                    brand: dto.brand,
                    isCustom: true
                )
            }
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
