//
//  TriGuide 2025
//

import Localization
import SwiftUI
import TriGuideDomain

public struct RaceCalculatorView: View {
    @State private var selectedSport: SupportedSport = .run

    @StateObject private var runViewModel: PaceCalculatorViewModel
    @StateObject private var swimViewModel: PaceCalculatorViewModel
    @StateObject private var bikeViewModel: PaceCalculatorViewModel

    @StateObject private var runSplitsViewModel: SplitsTableViewModel
    @StateObject private var swimSplitsViewModel: SplitsTableViewModel
    @StateObject private var bikeSplitsViewModel: SplitsTableViewModel

    public init(
        runViewModel: PaceCalculatorViewModel,
        swimViewModel: PaceCalculatorViewModel,
        bikeViewModel: PaceCalculatorViewModel,
        runSplitsViewModel: SplitsTableViewModel,
        swimSplitsViewModel: SplitsTableViewModel,
        bikeSplitsViewModel: SplitsTableViewModel
    ) {
        _runViewModel = StateObject(wrappedValue: runViewModel)
        _swimViewModel = StateObject(wrappedValue: swimViewModel)
        _bikeViewModel = StateObject(wrappedValue: bikeViewModel)
        _runSplitsViewModel = StateObject(wrappedValue: runSplitsViewModel)
        _swimSplitsViewModel = StateObject(wrappedValue: swimSplitsViewModel)
        _bikeSplitsViewModel = StateObject(wrappedValue: bikeSplitsViewModel)
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
                viewModel: swimViewModel
            )

            if let distance = swimViewModel.distance,
               distance > 0,
               let pace = swimViewModel.pace,
               pace > 0,
               let paceUnit = swimViewModel.paceUnit
            {
                SplitsTableView(
                    totalDistance: Binding(
                        get: { distance },
                        set: { swimViewModel.distance = $0 }
                    ),
                    pace: Binding(
                        get: { pace },
                        set: { swimViewModel.pace = $0 }
                    ),
                    paceUnit: Binding(
                        get: { paceUnit },
                        set: { swimViewModel.paceUnit = $0 }
                    ),
                    viewModel: swimSplitsViewModel
                )
            }
        }
    }

    var bikeTimeView: some View {
        VStack {
            PaceTimeCalculatorView<CyclingDistance>(
                sport: .bike,
                viewModel: bikeViewModel
            )

            if let distance = bikeViewModel.distance,
               distance > 0,
               let speed = bikeViewModel.speed,
               speed > 0,
               let paceUnit = bikeViewModel.paceUnit
            {
                SplitsTableView(
                    totalDistance: Binding(
                        get: { distance },
                        set: { bikeViewModel.distance = $0 }
                    ),
                    pace: Binding(
                        get: { speed },
                        set: { bikeViewModel.speed = $0 }
                    ),
                    paceUnit: Binding(
                        get: { paceUnit },
                        set: { bikeViewModel.paceUnit = $0 }
                    ),
                    viewModel: bikeSplitsViewModel
                )
            }
        }
    }

    var runTimeView: some View {
        VStack {
            PaceTimeCalculatorView<RunningDistance>(
                sport: .run,
                viewModel: runViewModel
            )

            if let distance = runViewModel.distance,
               distance > 0,
               let pace = runViewModel.pace,
               pace > 0,
               let paceUnit = runViewModel.paceUnit
            {
                SplitsTableView(
                    totalDistance: Binding(
                        get: { distance },
                        set: { runViewModel.distance = $0 }
                    ),
                    pace: Binding(
                        get: { pace },
                        set: { runViewModel.pace = $0 }
                    ),
                    paceUnit: Binding(
                        get: { paceUnit },
                        set: { runViewModel.paceUnit = $0 }
                    ),
                    viewModel: runSplitsViewModel
                )
            }
        }
    }

    var triathlonTimeView: some View {
        TriathlonTimeView(
            viewModel: TriathlonTimeViewModel()
        )
    }

    var duathlonTimeView: some View {
        DuathlonTimeView(
            viewModel: DuathlonTimeViewModel()
        )
    }
}

#Preview {
    RaceCalculatorView(
        runViewModel: PaceCalculatorViewModel(
            paceCalculator: RunningPaceCalculator(),
            paceUnit: .minPerKm
        ),
        swimViewModel: PaceCalculatorViewModel(
            paceCalculator: SwimmingPaceCalculator(),
            paceUnit: .minPer100m
        ),
        bikeViewModel: PaceCalculatorViewModel(
            paceCalculator: CyclingPaceCalculator(),
            paceUnit: .kmPerHour
        ),
        runSplitsViewModel: SplitsTableViewModel(
            paceCalculator: RunningPaceCalculator()
        ),
        swimSplitsViewModel: SplitsTableViewModel(
            paceCalculator: SwimmingPaceCalculator()
        ),
        bikeSplitsViewModel: SplitsTableViewModel(
            paceCalculator: CyclingPaceCalculator()
        )
    )
}
