//
//  TimeCalculatorView.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 1/7/25.
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

            ScrollView {
                VStack(spacing: 16) {
                    switch selectedSport {
                    case .swim:
                        swimTimeView
                    case .bike:
                        bikeTimeView
                    case .run:
                        runTimeView
                    case .triathlon:
                        triathlonTimeView
                    case .duathlon:
                        duathlonTimeView
                    }
                }
            }
        }
    }
}

private extension TimeCalculatorView {
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
        Text("Duathlon")
    }
}

#Preview {
    TimeCalculatorView()
}
