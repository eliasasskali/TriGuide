//
// TriGuide 2025
//

import Foundation

public protocol RemoteCarbItemsDataSource: Sendable {
    func fetchCarbItems() async throws -> [CarbItemDto]
}
