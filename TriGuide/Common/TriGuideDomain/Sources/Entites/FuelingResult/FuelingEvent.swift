//
// TriGuide 2025
//

import Foundation

public struct FuelingEvent: Equatable, Sendable, Hashable, Identifiable {
    public enum Consumption: Equatable, Sendable, Hashable {
        case instant(time: TimeInterval)
        case interval(start: TimeInterval, end: TimeInterval)
    }

    public let consumption: Consumption
    public let carbItem: CarbItem

    public init(consumption: Consumption, carbItem: CarbItem) {
        self.consumption = consumption
        self.carbItem = carbItem
    }

    public var consumptionTimeOrZero: TimeInterval {
        switch consumption {
        case .instant(let time): return time
        case .interval(let start, _): return start
        }
    }

    public var id: Int {
        self.hashValue
    }
}
