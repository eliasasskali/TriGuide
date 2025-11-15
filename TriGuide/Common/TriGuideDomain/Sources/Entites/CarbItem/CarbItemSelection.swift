//
// TriGuide 2025
//

import Foundation

public struct CarbItemSelection: Equatable, Identifiable, Hashable, Sendable {
    public let item: CarbItem
    public let quantity: Double

    public var id: String { item.id }

    public init(item: CarbItem, quantity: Double) {
        self.item = item
        self.quantity = quantity
    }
}
