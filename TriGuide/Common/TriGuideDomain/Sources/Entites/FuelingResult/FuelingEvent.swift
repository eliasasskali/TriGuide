//
// TriGuide 2025
//

import Foundation

public struct FuelingEvent: Equatable, Sendable, Hashable, Identifiable, Codable {
    // MARK: - Consumption

    public enum Consumption: Equatable, Sendable, Hashable, Codable {
        case instant(time: TimeInterval)
        case interval(start: TimeInterval, end: TimeInterval)
    }

    // MARK: - Dependencies

    public let consumption: Consumption
    public let carbItem: CarbItem

    // MARK: - Initializer

    public init(consumption: Consumption, carbItem: CarbItem) {
        self.consumption = consumption
        self.carbItem = carbItem
    }

    // MARK: - Computed Properties

    public var consumptionTimeOrZero: TimeInterval {
        switch consumption {
        case let .instant(time): return time
        case let .interval(start, _): return start
        }
    }

    public var id: Int {
        hashValue
    }
}
