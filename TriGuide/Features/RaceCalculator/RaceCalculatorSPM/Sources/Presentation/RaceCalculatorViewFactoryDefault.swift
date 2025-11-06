//
// TriGuide 2025
//

import Foundation

public final class RaceCalculatorViewFactoryDefault {
    public struct Dependencies {
        let running: SportCalculationBundle
        let swimming: SportCalculationBundle
        let cycling: SportCalculationBundle

        @MainActor
        public init(
            running: SportCalculationBundle? = nil,
            swimming: SportCalculationBundle? = nil,
            cycling: SportCalculationBundle? = nil
        ) {
            self.running = running ?? SportCalculationBundle(
                paceCalculator: RunningPaceCalculator(),
                paceUnit: .minPerKm
            )
            self.swimming = swimming ?? SportCalculationBundle(
                paceCalculator: SwimmingPaceCalculator(),
                paceUnit: .minPer100m
            )
            self.cycling = cycling ?? SportCalculationBundle(
                paceCalculator: CyclingPaceCalculator(),
                paceUnit: .kmPerHour
            )
        }
    }

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - RaceCalculatorViewFactory

extension RaceCalculatorViewFactoryDefault: RaceCalculatorViewFactory {
    @MainActor
    public func buildRaceCalculatorView() -> RaceCalculatorView {
        RaceCalculatorView(
            runViewModel: dependencies.running.paceCalculatorViewModel,
            swimViewModel: dependencies.swimming.paceCalculatorViewModel,
            bikeViewModel: dependencies.cycling.paceCalculatorViewModel,
            runSplitsViewModel: dependencies.running.splitsViewModel,
            swimSplitsViewModel: dependencies.swimming.splitsViewModel,
            bikeSplitsViewModel: dependencies.cycling.splitsViewModel
        )
    }
}

