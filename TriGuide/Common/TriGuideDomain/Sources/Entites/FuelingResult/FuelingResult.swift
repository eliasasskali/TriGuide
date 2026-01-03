//
// TriGuide 2025
//

import Foundation

public struct FuelingResult: Equatable, Sendable, Hashable {
    public var name: String?
    public let timeLine: [FuelingEvent]
    public let totalCarbsTarget: Double
    public let duration: TimeInterval
    public let selectedItems: [CarbItemSelection]
    public let hourlyBreakdown: [IntervalFueling]

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
}
