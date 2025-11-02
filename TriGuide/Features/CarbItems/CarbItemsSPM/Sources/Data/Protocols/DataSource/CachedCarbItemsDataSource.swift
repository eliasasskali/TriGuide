//
// TriGuide 2025
//

import Foundation

public protocol CachedCarbItemsDataSource: Sendable {
    func loadCarbItems() async throws -> [CarbItemDto]
    func saveCarbItems(_ items: [CarbItemDto]) async throws
}
