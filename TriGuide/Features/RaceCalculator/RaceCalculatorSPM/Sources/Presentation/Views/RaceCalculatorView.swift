//
//  TriGuide 2025
//

import Localization
import SwiftUI
import TriGuideDomain

public struct RaceCalculatorView: View {
    @State private var selectedSport: SupportedSport = .run
    @State private var selectedTriDistance: TriathlonDistance?
    @State private var selectedDuathlonDistance: DuathlonDistance?

    @ObservedObject private var coordinator: RaceCalculatorCoordinator

    public init(coordinator: RaceCalculatorCoordinator) {
        _coordinator = ObservedObject(wrappedValue: coordinator)
    }

    public var body: some View {
        VStack(spacing: 0) {
            Picker(Localizables.Common.sport, selection: $selectedSport) {
                ForEach(SupportedSport.allCases, id: \.self) { sport in
                    Text(sport.localized)
                }
            }
            .pickerStyle(.palette)
            .padding()
            .background(Color(UIColor.systemBackground))
            .zIndex(1)

            Divider()

            ScrollView {
                selectedSportView
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .floatingActionButton(Localizables.Common.reset, systemImage: "arrow.counterclockwise") {
            coordinator.resetSport(selectedSport)
            if selectedSport == .triathlon {
                selectedTriDistance = nil
            } else if selectedSport == .duathlon {
                selectedDuathlonDistance = nil
            }
        }
    }
}

private extension RaceCalculatorView {
    @ViewBuilder
    var selectedSportView: some View {
        switch selectedSport {
        case .swim: swimTimeView
        case .bike: bikeTimeView
        case .run: runTimeView
        case .triathlon: triathlonTimeView
        case .duathlon: duathlonTimeView
        }
    }

    var swimTimeView: some View {
        VStack {
            PaceTimeCalculatorView<SwimmingDistance>(
                sport: .swim,
                viewModel: coordinator.swimViewModel
            )

            if let distance = coordinator.swimViewModel.distance,
               distance > 0,
               let pace = coordinator.swimViewModel.pace,
               pace > 0,
               let paceUnit = coordinator.swimViewModel.paceUnit
            {
                SplitsTableView(
                    totalDistance: Binding(
                        get: { distance },
                        set: { coordinator.swimViewModel.distance = $0 }
                    ),
                    pace: Binding(
                        get: { pace },
                        set: { coordinator.swimViewModel.pace = $0 }
                    ),
                    paceUnit: Binding(
                        get: { paceUnit },
                        set: { coordinator.swimViewModel.paceUnit = $0 }
                    ),
                    splitsDistance: Binding(
                        get: { coordinator.swimViewModel.splitsDistance ?? paceUnit.defaultSplitsDistance },
                        set: { coordinator.swimViewModel.splitsDistance = $0 }
                    ),
                    viewModel: coordinator.swimSplitsViewModel
                )
            }
        }
    }

    var bikeTimeView: some View {
        VStack {
            PaceTimeCalculatorView<CyclingDistance>(
                sport: .bike,
                viewModel: coordinator.bikeViewModel
            )

            if let distance = coordinator.bikeViewModel.distance,
               distance > 0,
               let speed = coordinator.bikeViewModel.speed,
               speed > 0,
               let paceUnit = coordinator.bikeViewModel.paceUnit
            {
                SplitsTableView(
                    totalDistance: Binding(
                        get: { distance },
                        set: { coordinator.bikeViewModel.distance = $0 }
                    ),
                    pace: Binding(
                        get: { speed },
                        set: { coordinator.bikeViewModel.speed = $0 }
                    ),
                    paceUnit: Binding(
                        get: { paceUnit },
                        set: { coordinator.bikeViewModel.paceUnit = $0 }
                    ),
                    splitsDistance: Binding(
                        get: { coordinator.bikeViewModel.splitsDistance ?? paceUnit.defaultSplitsDistance },
                        set: { coordinator.bikeViewModel.splitsDistance = $0 }
                    ),
                    viewModel: coordinator.bikeSplitsViewModel
                )
            }
        }
    }

    var runTimeView: some View {
        VStack {
            PaceTimeCalculatorView<RunningDistance>(
                sport: .run,
                viewModel: coordinator.runViewModel
            )

            if let distance = coordinator.runViewModel.distance,
               distance > 0,
               let pace = coordinator.runViewModel.pace,
               pace > 0,
               let paceUnit = coordinator.runViewModel.paceUnit
            {
                SplitsTableView(
                    totalDistance: Binding(
                        get: { distance },
                        set: { coordinator.runViewModel.distance = $0 }
                    ),
                    pace: Binding(
                        get: { pace },
                        set: { coordinator.runViewModel.pace = $0 }
                    ),
                    paceUnit: Binding(
                        get: { paceUnit },
                        set: { coordinator.runViewModel.paceUnit = $0 }
                    ),
                    splitsDistance: Binding(
                        get: { coordinator.runViewModel.splitsDistance ?? paceUnit.defaultSplitsDistance },
                        set: { coordinator.runViewModel.splitsDistance = $0 }
                    ),
                    viewModel: coordinator.runSplitsViewModel
                )
            }
        }
    }

    var triathlonTimeView: some View {
        TriathlonTimeView(
            viewModel: coordinator.triathlonViewModel,
            swimViewModel: coordinator.triathlonSwimViewModel,
            bikeViewModel: coordinator.triathlonBikeViewModel,
            runViewModel: coordinator.triathlonRunViewModel,
            selectedTriDistance: $selectedTriDistance
        )
    }

    var duathlonTimeView: some View {
        DuathlonTimeView(
            viewModel: coordinator.duathlonViewModel,
            firstRunViewModel: coordinator.duathlonFirstRunViewModel,
            bikeViewModel: coordinator.duathlonBikeViewModel,
            secondRunViewModel: coordinator.duathlonSecondRunViewModel,
            selectedDuathlonDistance: $selectedDuathlonDistance
        )
    }
}

#Preview {
    RaceCalculatorCoordinator(
        factory: RaceCalculatorViewFactoryDefault(dependencies: .init()),
        running: SportCalculationBundle(
            paceCalculator: RunningPaceCalculator(),
            paceUnit: .minPerKm
        ),
        swimming: SportCalculationBundle(
            paceCalculator: SwimmingPaceCalculator(),
            paceUnit: .minPer100m
        ),
        cycling: SportCalculationBundle(
            paceCalculator: CyclingPaceCalculator(),
            paceUnit: .kmPerHour
        )
    ).start()
}
