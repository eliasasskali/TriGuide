//
// TriGuide 2025
//

import Foundation

public protocol LocalCarbItemsDataSource: Sendable {
    func loadCarbItems() async throws -> [CarbItemDto]
    func saveCarbItems(_ items: [CarbItemDto]) async throws
    func addCarbItem(_ item: CarbItemDto) async throws
    func removeCarbItem(id: String) async throws
}
