//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

extension FuelingResult {
    static let mock = buildMock()

    static func buildMock(
        name: String? = nil,
        itemId: String = "item-1",
        itemName: String = "Gel",
        carbs: Double = 30,
        quantity: Double = 1,
        duration: TimeInterval = 3600
    ) -> FuelingResult {
        let item = CarbItem(
            id: itemId,
            name: itemName,
            gramsOfCarbs: carbs,
            type: .gel
        )

        let event = FuelingEvent(
            consumption: .instant(time: 600),
            carbItem: item
        )

        let selection = CarbItemSelection(item: item, quantity: quantity)

        let interval = IntervalFueling(
            duration: 3600,
            hourIndex: 0,
            carbGrams: carbs,
            caffeine: 0,
            waterVolumeML: 0
        )

        return FuelingResult(
            name: name,
            timeLine: [event],
            totalCarbsTarget: carbs,
            duration: duration,
            selectedItems: [selection],
            hourlyBreakdown: [interval]
        )
    }
}
