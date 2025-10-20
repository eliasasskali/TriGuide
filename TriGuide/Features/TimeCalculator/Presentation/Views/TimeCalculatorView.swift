//
//  TriGuide 2025
//

import SwiftUI
import Localization

struct TimeCalculatorView: View {
    @State private var selectedSport: SupportedSport = .run
    
    @StateObject private var runViewModel = PaceCalculatorViewModel(
            paceCalculator: RunningPaceCalculator()
        )
    
    @StateObject private var swimViewModel = PaceCalculatorViewModel(
            paceCalculator: SwimmingPaceCalculator()
        )
    
    @StateObject private var bikeViewModel = PaceCalculatorViewModel(
            paceCalculator: CyclingPaceCalculator()
        )
    
    @StateObject private var runSplitsViewModel = SplitsTableViewModel(
            paceCalculator: RunningPaceCalculator()
        )
    
    @StateObject private var swimSplitsViewModel = SplitsTableViewModel(
            paceCalculator: SwimmingPaceCalculator()
        )
    
    @StateObject private var bikeSplitsViewModel = SplitsTableViewModel(
            paceCalculator: CyclingPaceCalculator()
        )
    
    var body: some View {
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

private extension TimeCalculatorView {
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
               let pace = swimViewModel.pace,
               let paceUnit = swimViewModel.paceUnit {
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
               let speed = bikeViewModel.speed,
               let paceUnit = bikeViewModel.paceUnit {
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
               let pace = runViewModel.pace,
               let paceUnit = runViewModel.paceUnit {
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
    TimeCalculatorView()
}
