//
// TriGuide 2025
//

import Foundation

public protocol CarbItemsRepository: Sendable {
    func getCarbItems(forceRefresh: Bool) async throws -> [CarbItem]
}
