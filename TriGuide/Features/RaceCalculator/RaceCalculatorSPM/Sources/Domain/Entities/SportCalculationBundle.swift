//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public struct SportCalculationBundle {
    public let paceCalculator: any PaceCalculator
    public let paceCalculatorViewModel: PaceCalculatorViewModel
    public let splitsViewModel: SplitsTableViewModel

    @MainActor
    public init(
        paceCalculator: some PaceCalculator,
        paceUnit: SpeedUnit
    ) {
        self.paceCalculator = paceCalculator
        self.paceCalculatorViewModel = PaceCalculatorViewModel(
            paceCalculator: paceCalculator,
            paceUnit: paceUnit
        )
        self.splitsViewModel = SplitsTableViewModel(
            paceCalculator: paceCalculator
        )
    }
}
