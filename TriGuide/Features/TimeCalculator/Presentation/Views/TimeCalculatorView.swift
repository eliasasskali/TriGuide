//
//  TriGuide 2025
//

import SwiftUI

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
        PaceTimeCalculatorView<SwimmingDistance>(
            sport: .swim,
            viewModel: swimViewModel
        )
    }
    
    var bikeTimeView: some View {
        PaceTimeCalculatorView<CyclingDistance>(
            sport: .bike,
            viewModel: bikeViewModel
        )
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
