//
//  TriathlonTimeView.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 12/7/25.
//

import SwiftUI

struct TriathlonTimeView: View {
    @StateObject var viewModel: TriathlonTimeViewModel

    @State var selectedTriDistance: TriathlonDistance? = nil

    var body: some View {
        VStack(spacing: 16) {
            triDistancePicker

            PaceTimeCalculatorView<SwimmingDistance>(
                sport: .swim,
                viewModel: PaceCalculatorViewModel(
                    paceCalculator: SwimmingPaceCalculator()
                ),
                selectedRaceDistance: Binding(
                    get: { selectedTriDistance?.swimmingDistance },
                    set: { _ in
                        selectedTriDistance = nil
                    }
                ),
                duration: $viewModel.swimTime
            )

            DurationPickerView(
                title: "T2 Time",
                mode: .compact,
                duration: $viewModel.t1Time
            )

            PaceTimeCalculatorView<CyclingDistance>(
                sport: .bike,
                viewModel: PaceCalculatorViewModel(
                    paceCalculator: CyclingPaceCalculator()
                ),
                selectedRaceDistance: Binding(
                    get: { selectedTriDistance?.cyclingDistance },
                    set: { _ in
                        selectedTriDistance = nil
                    }
                ),
                duration: $viewModel.cyclingTime
            )

            DurationPickerView(
                title: "T2 Time",
                mode: .compact,
                duration: $viewModel.t2Time
            )

            PaceTimeCalculatorView<RunningDistance>(
                sport: .run,
                viewModel: PaceCalculatorViewModel(
                    paceCalculator: RunningPaceCalculator()
                ),
                selectedRaceDistance: Binding(
                    get: { selectedTriDistance?.runningDistance },
                    set: { _ in
                        selectedTriDistance = nil
                    }
                ),
                duration: $viewModel.runningTime
            )

            totalTime
        }
    }
}

private extension TriathlonTimeView {
    var triDistancePicker: some View {
        Menu {
            Picker("Triathlon Distance", selection: $selectedTriDistance) {
                Text("Select race").tag(nil as TriathlonDistance?)
                ForEach(TriathlonDistance.allCases, id: \.self) { distance in
                    Text(distance.displayName).tag(Optional(distance))
                }
            }
        } label: {
            HStack {
                Text("Triathlon Distance: ")
                    .font(.Custom.Medium.font4)
                Text(selectedTriDistance?.displayName ?? "Select race")
                    .font(.Custom.Regular.font4)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }

    var totalTime: some View {
        Text("Total time: \(viewModel.formattedTotalTime)")
            .font(.Custom.Medium.font5)

    }
}

#Preview {
    TriathlonTimeView(
        viewModel: TriathlonTimeViewModel()
    )
}
