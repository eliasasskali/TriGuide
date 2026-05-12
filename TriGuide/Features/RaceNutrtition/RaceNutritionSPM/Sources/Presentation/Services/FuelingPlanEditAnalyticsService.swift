//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

// MARK: - FuelingPlanEditAnalyticsData

public struct FuelingPlanEditAnalyticsData {
    public struct TimelineEntry {
        public let itemName: String
        public let itemId: String
        public let isCustom: Bool
        public let positionSeconds: Double

        public init(from event: FuelingEvent) {
            itemName = event.carbItem.name
            itemId = event.carbItem.id
            isCustom = event.carbItem.isCustom
            positionSeconds = event.consumptionTimeOrZero
        }
    }

    public let calculationId: String?
    public let originalTimeline: [TimelineEntry]
    public let editedTimeline: [TimelineEntry]
    public let itemsMovedCount: Int
    public let averageShiftSeconds: Double
    public let maxShiftSeconds: Double

    public init(original: FuelingResult, edited: FuelingResult, calculationId: String? = nil) {
        self.calculationId = calculationId
        originalTimeline = original.timeLine
            .sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
            .map { TimelineEntry(from: $0) }
        editedTimeline = edited.timeLine
            .sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
            .map { TimelineEntry(from: $0) }

        // Compute edit summary by matching items by ID and index
        var movedCount = 0
        var totalShift = 0.0
        var maxShift = 0.0

        let originalById = Dictionary(grouping: originalTimeline) { $0.itemId }
        let editedById = Dictionary(grouping: editedTimeline) { $0.itemId }

        for (itemId, originalEntries) in originalById {
            guard let editedEntries = editedById[itemId] else { continue }
            let pairCount = min(originalEntries.count, editedEntries.count)
            for i in 0 ..< pairCount {
                let shift = editedEntries[i].positionSeconds - originalEntries[i].positionSeconds
                if abs(shift) > 1 {
                    movedCount += 1
                    totalShift += shift
                    maxShift = max(maxShift, abs(shift))
                }
            }
        }

        itemsMovedCount = movedCount
        averageShiftSeconds = movedCount > 0 ? totalShift / Double(movedCount) : 0
        maxShiftSeconds = maxShift
    }
}

// MARK: - FuelingPlanEditAnalyticsService

public protocol FuelingPlanEditAnalyticsService {
    func trackScreenView()
    func trackPlanEdited(data: FuelingPlanEditAnalyticsData)
}
