//
// TriGuide 2025
//

import Foundation

public struct FuelingEvent: Equatable, Sendable, Hashable {
    public let time: TimeInterval
    public let carbItem: CarbItem

    public init(time: TimeInterval, carbItem: CarbItem) {
        self.time = time
        self.carbItem = carbItem
    }
}
