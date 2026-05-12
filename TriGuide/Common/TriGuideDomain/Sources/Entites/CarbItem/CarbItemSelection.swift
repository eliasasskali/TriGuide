//
// TriGuide 2025
//

import Foundation

public struct CarbItemSelection: Equatable, Identifiable, Hashable, Sendable, Codable {
    // MARK: - Dependencies

    public let item: CarbItem
    public let quantity: Double

    // MARK: - Computed Properties

    public var id: String { item.id }

    // MARK: - Initializer

    public init(item: CarbItem, quantity: Double) {
        self.item = item
        self.quantity = quantity
    }
}
