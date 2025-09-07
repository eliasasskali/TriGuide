//
//  TriGuide 2025
//

import SwiftUI

struct DuathlonTimeView: View {
    @StateObject var viewModel: DuathlonTimeViewModel

    @State var selectedDuathlonDistance: DuathlonDistance? = nil

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                ScrollView {
                    calculatorViews
                        .padding(.bottom)
                }

                TotalTimeView(time: viewModel.formattedTotalTime)
            }
        }
    }
}

private extension DuathlonTimeView {
    var calculatorViews: some View {
        VStack(spacing: 16) {
            duathlonDistancePicker

            firstRunCalculatorView

            DurationPickerView(
                title: "T1 Time",
                mode: .compact,
                labelsBackgroundColor: Color.primaryWhite,
                duration: $viewModel.t1Time
            )
            .padding(.horizontal, 4)

            bikeCalulatorView

            DurationPickerView(
                title: "T2 Time",
                mode: .compact,
                labelsBackgroundColor: Color.primaryWhite,
                duration: $viewModel.t2Time
            )
            .padding(.horizontal, 4)

            secondRunCalculatorView
        }
    }

    var duathlonDistancePicker: some View {
        Menu {
            Picker("Duathlon Distance", selection: $selectedDuathlonDistance) {
                Text("Select race").tag(nil as DuathlonDistance?)
                ForEach(DuathlonDistance.allCases, id: \.self) { distance in
                    Text(distance.displayName).tag(Optional(distance))
                }
            }
        } label: {
            HStack {
                Text("Duathlon Distance: ")
                    .font(.Custom.Medium.font4)
                    .foregroundStyle(.black)
                Text(selectedDuathlonDistance?.displayName ?? "Select race")
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

    var firstRunCalculatorView: some View {
        PaceTimeCalculatorView<RunningDistance>(
            sport: .run,
            viewModel: PaceCalculatorViewModel(
                paceCalculator: RunningPaceCalculator()
            ),
            selectedRaceDistance: Binding(
                get: { selectedDuathlonDistance?.firstRunDistance },
                set: { _ in
                    selectedDuathlonDistance = nil
                }
            ),
            duration: $viewModel.firstRunTime
        )
    }

    var bikeCalulatorView: some View {
        PaceTimeCalculatorView<CyclingDistance>(
            sport: .bike,
            viewModel: PaceCalculatorViewModel(
                paceCalculator: CyclingPaceCalculator()
            ),
            selectedRaceDistance: Binding(
                get: { selectedDuathlonDistance?.cyclingDistance },
                set: { _ in
                    selectedDuathlonDistance = nil
                }
            ),
            duration: $viewModel.cyclingTime
        )
    }

    var secondRunCalculatorView: some View {
        PaceTimeCalculatorView<RunningDistance>(
            sport: .run,
            viewModel: PaceCalculatorViewModel(
                paceCalculator: RunningPaceCalculator()
            ),
            selectedRaceDistance: Binding(
                get: { selectedDuathlonDistance?.secondRunDistance },
                set: { _ in
                    selectedDuathlonDistance = nil
                }
            ),
            duration: $viewModel.secondRunTime
        )
    }
}

#Preview {
    DuathlonTimeView(
        viewModel: DuathlonTimeViewModel()
    )
}
