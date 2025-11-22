//
// TriGuide
//

import Foundation
import TriGuideDomain

public protocol FuelingCalculatorDataSource: Sendable {
    func calculateFueling(from fuelingInput: FuelingInput) -> FuelingResult
    func computeBreakDown(
        minutes: Double,
        totalDuration: TimeInterval,
        events: [FuelingEvent]
    ) -> [IntervalFueling]
}
