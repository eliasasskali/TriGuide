//
//  TriGuide 2025
//

import SwiftUI

struct TimeCalculatorView: View {
    @State private var selectedSport: SupportedSport = .run

    var body: some View {
        VStack(spacing: 0) {
            Picker("Sport", selection: $selectedSport) {
                ForEach(SupportedSport.allCases, id: \.self) { sport in
                    Text(sport.localized)
                }
            }
            .pickerStyle(.palette)
            .padding()
            .background(Color(UIColor.systemBackground))
            .zIndex(1)

            Divider()

            selectedSportView
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
            viewModel: PaceCalculatorViewModel(
                paceCalculator: SwimmingPaceCalculator()
            )
        )
    }

    var bikeTimeView: some View {
        PaceTimeCalculatorView<CyclingDistance>(
            sport: .bike,
            viewModel: PaceCalculatorViewModel(
                paceCalculator: CyclingPaceCalculator()
            )
        )
    }

    var runTimeView: some View {
        PaceTimeCalculatorView<RunningDistance>(
            sport: .run,
            viewModel: PaceCalculatorViewModel(
                paceCalculator: RunningPaceCalculator()
            )
        )
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
