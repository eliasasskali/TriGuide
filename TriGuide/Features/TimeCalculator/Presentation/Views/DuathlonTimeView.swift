//
//  TriGuide 2025
//

import SwiftUI

struct DuathlonTimeView: View {
    @StateObject var viewModel: DuathlonTimeViewModel

    @State var selectedDuathlonDistance: DuathlonDistance? = nil

    var body: some View {
        VStack(spacing: 16) {
            duathlonDistancePicker

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

            DurationPickerView(
                title: "T1 Time",
                mode: .compact,
                duration: $viewModel.t1Time
            )

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
                    get: { selectedDuathlonDistance?.secondRunDistance },
                    set: { _ in
                        selectedDuathlonDistance = nil
                    }
                ),
                duration: $viewModel.secondRunTime
            )

            totalTime
        }
    }
}

private extension DuathlonTimeView {
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
                Text("Triathlon Distance: ")
                    .font(.Custom.Medium.font4)
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

    var totalTime: some View {
        Text("Total time: \(viewModel.formattedTotalTime)")
            .font(.Custom.Medium.font5)

    }
}

#Preview {
    DuathlonTimeView(
        viewModel: DuathlonTimeViewModel()
    )
}
