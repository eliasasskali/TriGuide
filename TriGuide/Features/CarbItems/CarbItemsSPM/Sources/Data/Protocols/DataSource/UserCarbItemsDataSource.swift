//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public protocol UserCarbItemsDataSource: Sendable {
    func getCarbItems() async throws -> [CarbItem]
    func addCarbItem(_ item: CarbItem) async throws
    func deleteCarbItem(id: String) async throws
}
