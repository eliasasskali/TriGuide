//
// TriGuide 2025
//

import Foundation

public struct CarbItemSelection: Equatable, Identifiable, Hashable {
    public let item: CarbItem
    public let quantity: Double

    public var id: String { item.id }
}
