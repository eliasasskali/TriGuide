//
// TriGuide 2025
//

import Combine
import Foundation
import NavigationKit
import TriGuideDomain

public class RaceCalculatorCoordinator: BaseCoordinator<Never, Never, RaceCalculatorView> {
    let factory: RaceCalculatorViewFactory
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Single-sport view models

    let runViewModel: PaceCalculatorViewModel
    let swimViewModel: PaceCalculatorViewModel
    let bikeViewModel: PaceCalculatorViewModel
    let runSplitsViewModel: SplitsTableViewModel
    let swimSplitsViewModel: SplitsTableViewModel
    let bikeSplitsViewModel: SplitsTableViewModel

    // MARK: - Multi-sport view models

    let triathlonViewModel = TriathlonTimeViewModel()
    let duathlonViewModel = DuathlonTimeViewModel()

    let triathlonSwimViewModel = PaceCalculatorViewModel(
        paceCalculator: SwimmingPaceCalculator(),
        paceUnit: .minPer100m
    )
    let triathlonBikeViewModel = PaceCalculatorViewModel(
        paceCalculator: CyclingPaceCalculator(),
        paceUnit: .kmPerHour
    )
    let triathlonRunViewModel = PaceCalculatorViewModel(
        paceCalculator: RunningPaceCalculator(),
        paceUnit: .minPerKm
    )

    let duathlonFirstRunViewModel = PaceCalculatorViewModel(
        paceCalculator: RunningPaceCalculator(),
        paceUnit: .minPerKm
    )
    let duathlonBikeViewModel = PaceCalculatorViewModel(
        paceCalculator: CyclingPaceCalculator(),
        paceUnit: .kmPerHour
    )
    let duathlonSecondRunViewModel = PaceCalculatorViewModel(
        paceCalculator: RunningPaceCalculator(),
        paceUnit: .minPerKm
    )

    // MARK: - Initializer

    public init(
        factory: RaceCalculatorViewFactory,
        running: SportCalculationBundle,
        swimming: SportCalculationBundle,
        cycling: SportCalculationBundle
    ) {
        self.factory = factory
        runViewModel = running.paceCalculatorViewModel
        swimViewModel = swimming.paceCalculatorViewModel
        bikeViewModel = cycling.paceCalculatorViewModel
        runSplitsViewModel = running.splitsViewModel
        swimSplitsViewModel = swimming.splitsViewModel
        bikeSplitsViewModel = cycling.splitsViewModel
        super.init()

        for vm in [runViewModel, swimViewModel, bikeViewModel] {
            vm.objectWillChange
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }
        for vm in [runSplitsViewModel, swimSplitsViewModel, bikeSplitsViewModel] {
            vm.objectWillChange
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }
    }

    override public func start() -> RaceCalculatorView {
        RaceCalculatorView(coordinator: self)
    }

    // MARK: - Reset

    func resetSport(_ sport: SupportedSport) {
        switch sport {
        case .swim:
            swimViewModel.reset()
            swimSplitsViewModel.splits = []
        case .bike:
            bikeViewModel.reset()
            bikeSplitsViewModel.splits = []
        case .run:
            runViewModel.reset()
            runSplitsViewModel.splits = []
        case .triathlon:
            triathlonViewModel.reset()
            triathlonSwimViewModel.reset()
            triathlonBikeViewModel.reset()
            triathlonRunViewModel.reset()
        case .duathlon:
            duathlonViewModel.reset()
            duathlonFirstRunViewModel.reset()
            duathlonBikeViewModel.reset()
            duathlonSecondRunViewModel.reset()
        }
    }
}
