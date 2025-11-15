//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public struct LocalFuelingCalculator: FuelingCalculatorDataSource {
    public func calculateFueling(from fuelingInput: FuelingInput) -> TriGuideDomain.FuelingResult {
        .init(
            timeLine: [
                FuelingEvent(time: TimeInterval(7200/5), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(time: TimeInterval(7200*2/5), carbItem: .init(id: "id2", name: "gel 2", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(time: TimeInterval(7200*3/5), carbItem: .init(id: "id3", name: "gel 3", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(time: TimeInterval(7200*4/5), carbItem: .init(id: "id4", name: "gel 4", gramsOfCarbs: 45, type: .gel))
            ],
            totalCarbsTarget: fuelingInput.carbsTarget,
            duration: fuelingInput.duration,
            selectedItems: fuelingInput.carbItemSelection
        )
    }
}
