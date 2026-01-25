//
// TriGuide 2025
//

import Foundation
import TriGuideDomain
@testable import CarbItemsSPM

final actor UserCarbItemsDataSourceMock: UserCarbItemsDataSource {
    var items: [CarbItem] = []

    func getCarbItems() async throws -> [CarbItem] {
        return items
    }

    func addCarbItem(_ item: CarbItem) async throws {
        items.append(item)
    }

    func deleteCarbItem(id: String) async throws {
        items.removeAll { $0.id == id }
    }
}
