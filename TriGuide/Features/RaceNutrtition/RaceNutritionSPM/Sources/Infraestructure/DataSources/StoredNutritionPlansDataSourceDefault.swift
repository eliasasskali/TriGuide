//
// TriGuide 2026
//

import Foundation
import StorageKit
import TriGuideDomain

actor StoredNutritionPlansDataSourceDefault: StoredNutritionPlansDataSource {
    // MARK: - Constants

    enum Constants {
        static let fileName = "nutrition_plans_cache"
    }

    // MARK: - Dependencies

    private let storage: LocalStorage<[FuelingResult]>

    // MARK: - Initializer

    init(storage: LocalStorage<[FuelingResult]>? = nil) throws {
        if let storage {
            self.storage = storage
        } else {
            self.storage = try LocalStorage<[FuelingResult]>(
                fileName: Constants.fileName,
                directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            )
        }
    }

    // MARK: - CachedCarbItemsDataSource

    func loadNutritionPlans() async throws -> [FuelingResult] {
        do {
            return try await storage.load()
        } catch LocalStorageError.fileNotFound {
            return []
        }
    }

    func saveNutritionPlans(_ plans: [FuelingResult]) async throws {
        try await storage.save(plans)
    }
}
