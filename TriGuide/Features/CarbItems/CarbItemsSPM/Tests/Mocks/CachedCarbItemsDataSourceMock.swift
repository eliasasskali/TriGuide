//
// TriGuide 2025
//

import Foundation
import CarbItemsSPM

final actor CachedCarbItemsDataSourceMock: CachedCarbItemsDataSource {
    var dtos: [CarbItemDto]
    var didSave: Bool
    let shouldThrowOnLoad: Bool
    let shouldThrowOnSave: Bool

    init(
        dtos: [CarbItemDto] = [],
        didSave: Bool = false,
        shouldThrowOnLoad: Bool = false,
        shouldThrowOnSave: Bool = false
    ) {
        self.dtos = dtos
        self.didSave = didSave
        self.shouldThrowOnLoad = shouldThrowOnLoad
        self.shouldThrowOnSave = shouldThrowOnSave
    }

    func loadCarbItems() async throws -> [CarbItemDto] {
        if shouldThrowOnLoad { throw NSError(domain: "CacheLoadError", code: 2) }
        return dtos
    }

    func saveCarbItems(_ items: [CarbItemDto]) async throws {
        if shouldThrowOnSave { throw NSError(domain: "CacheSaveError", code: 3) }
        didSave = true
        self.dtos = items
    }
}
