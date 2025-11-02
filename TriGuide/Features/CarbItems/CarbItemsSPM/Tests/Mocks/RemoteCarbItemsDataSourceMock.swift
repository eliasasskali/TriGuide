//
// TriGuide 2025
//

import Foundation
import CarbItemsSPM

final actor RemoteCarbItemsDataSourceMock: RemoteCarbItemsDataSource {
    var dtos: [CarbItemDto]
    var shouldThrow: Bool

    init(dtos: [CarbItemDto] = [], shouldThrow: Bool = false) {
        self.dtos = dtos
        self.shouldThrow = shouldThrow
    }

    func fetchCarbItems() async throws -> [CarbItemDto] {
        if shouldThrow { throw NSError(domain: "RemoteError", code: 1) }
        return dtos
    }
}
