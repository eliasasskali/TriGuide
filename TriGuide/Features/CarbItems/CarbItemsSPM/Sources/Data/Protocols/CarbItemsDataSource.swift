//
// TriGuide 2025
//

import Foundation

public protocol CarbItemsDataSource: Sendable {
    func fetchCarbItems() async throws -> [CarbItemDto]
}
