//
// TriGuide 2025
//

@testable import CarbItemsSPM
import Foundation
import TriGuideDomain

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
