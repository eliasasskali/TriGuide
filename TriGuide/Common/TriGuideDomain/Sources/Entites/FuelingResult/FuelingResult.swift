//
// TriGuide 2025
//

import Foundation

public struct FuelingResult: Equatable, Sendable, Hashable, Codable {
    // MARK: - Depdencies

    public var name: String?
    public let timeLine: [FuelingEvent]
    public let totalCarbsTarget: Double
    public let duration: TimeInterval
    public let selectedItems: [CarbItemSelection]
    public let hourlyBreakdown: [IntervalFueling]

    // MARK: - Computed Properties

    public var totalSelectedCarbs: Double {
        selectedItems.reduce(0) { $0 + $1.item.gramsOfCarbs * $1.quantity }
    }

    public var carbTargetPerHour: Double {
        totalCarbsTarget / (duration / 3600)
    }

    public var actualCarbsPerHour: Double {
        totalSelectedCarbs / (duration / 3600)
    }

    public var instantEvents: [FuelingEvent] {
        timeLine.filter { event in
            switch event.consumption {
            case .instant: return true
            case .interval: return false
            }
        }
    }

    public var intervalEvents: [FuelingEvent] {
        timeLine.filter { event in
            switch event.consumption {
            case .instant: return false
            case .interval: return true
            }
        }
    }

    // MARK: - Initializer

    public init(
        name: String? = nil,
        timeLine: [FuelingEvent],
        totalCarbsTarget: Double,
        duration: TimeInterval,
        selectedItems: [CarbItemSelection],
        hourlyBreakdown: [IntervalFueling]
    ) {
        self.name = name
        self.timeLine = timeLine
        self.totalCarbsTarget = totalCarbsTarget
        self.duration = duration
        self.selectedItems = selectedItems
        self.hourlyBreakdown = hourlyBreakdown
    }

    // MARK: - Equatable

    public static func == (lhs: FuelingResult, rhs: FuelingResult) -> Bool {
        lhs.timeLine == rhs.timeLine &&
            lhs.totalCarbsTarget == rhs.totalCarbsTarget &&
            lhs.duration == rhs.duration &&
            lhs.selectedItems == rhs.selectedItems &&
            lhs.hourlyBreakdown == rhs.hourlyBreakdown
    }
}
