//
//  TriGuide 2025
//

import SwiftUI
import Localization
import DesignSystem

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
                .scrollIndicators(.hidden)

                TotalTimeLabel(time: viewModel.formattedTotalTime)
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
                title: Localizables.PaceCalculator.transitionTime(transitionNumber: 1),
                mode: .compact,
                labelsBackgroundColor: Color.Primary.white,
                showHours: false,
                duration: $viewModel.t1Time
            )
            .padding(.horizontal, 4)

            bikeCalulatorView

            DurationPickerView(
                title: Localizables.PaceCalculator.transitionTime(transitionNumber: 2),
                mode: .compact,
                labelsBackgroundColor: Color.Primary.white,
                showHours: false,
                duration: $viewModel.t2Time
            )
            .padding(.horizontal, 4)

            secondRunCalculatorView
        }
    }

    var duathlonDistancePicker: some View {
        Menu {
            Picker(Localizables.PaceCalculator.duathlonDistance, selection: $selectedDuathlonDistance) {
                Text(Localizables.PaceCalculator.race).tag(nil as DuathlonDistance?)
                ForEach(DuathlonDistance.allCases, id: \.self) { distance in
                    Text(distance.displayName).tag(Optional(distance))
                }
            }
        } label: {
            HStack {
                Text(Localizables.PaceCalculator.duathlonDistance)
                    .font(.Custom.Medium.font4)
                    .foregroundStyle(.black)
                Text(selectedDuathlonDistance?.displayName ?? Localizables.PaceCalculator.race)
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
                paceCalculator: RunningPaceCalculator(),
                paceUnit: .minPerKm
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
                paceCalculator: CyclingPaceCalculator(),
                paceUnit: .kmPerHour
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
                paceCalculator: RunningPaceCalculator(),
                paceUnit: .minPerKm
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
