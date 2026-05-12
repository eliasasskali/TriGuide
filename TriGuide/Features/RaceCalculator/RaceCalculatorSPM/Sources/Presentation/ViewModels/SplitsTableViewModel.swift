//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

@MainActor
public final class SplitsTableViewModel: ObservableObject {
    let paceCalculator: PaceCalculator

    @Published var splits: [RaceSplit] = []

    public init(paceCalculator: PaceCalculator) {
        self.paceCalculator = paceCalculator
    }

    func updateSplits(
        splitsDistance: Double,
        totalDistance: Double,
        pace: TimeInterval,
        paceUnit: SpeedUnit
    ) {
        guard splitsDistance > 0, totalDistance > 0, pace > 0 else {
            splits = []
            return
        }

        var newSplits: [RaceSplit] = []
        var cumulativeTime = 0.0

        guard let splitTime = paceCalculator.calculateTime(
            pace: pace,
            distance: splitsDistance,
            paceUnit: paceUnit
        ) else { return }
        for cumulativeDistance in stride(from: splitsDistance, through: totalDistance, by: splitsDistance) {
            cumulativeTime += splitTime
            newSplits.append(
                RaceSplit(
                    distance: cumulativeDistance,
                    splitTime: splitTime,
                    cumulativeTime: cumulativeTime
                )
            )
        }

        let remainingDistance = totalDistance.truncatingRemainder(dividingBy: splitsDistance)
        if remainingDistance > 0 {
            if let remainderSplitTime = paceCalculator.calculateTime(
                pace: pace,
                distance: remainingDistance,
                paceUnit: paceUnit
            ) {
                cumulativeTime += remainderSplitTime
                newSplits.append(
                    RaceSplit(
                        distance: totalDistance,
                        splitTime: remainderSplitTime,
                        cumulativeTime: cumulativeTime
                    )
                )
            }
        }

        splits = newSplits
    }
}
