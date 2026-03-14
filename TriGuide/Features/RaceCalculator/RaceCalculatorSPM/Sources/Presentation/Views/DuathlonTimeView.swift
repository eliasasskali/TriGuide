//
//  TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

struct DuathlonTimeView: View {
    @ObservedObject var viewModel: DuathlonTimeViewModel
    @ObservedObject var firstRunViewModel: PaceCalculatorViewModel
    @ObservedObject var bikeViewModel: PaceCalculatorViewModel
    @ObservedObject var secondRunViewModel: PaceCalculatorViewModel

    @Binding var selectedDuathlonDistance: DuathlonDistance?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                calculatorViews
                    .padding(.bottom)
            }
            .scrollIndicators(.hidden)

            Divider()
            TotalTimeLabel(time: viewModel.formattedTotalTime)
                .padding(.horizontal)
                .padding(.vertical, 8)
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
                showHours: false,
                duration: $viewModel.t1Time
            )
            .padding(.horizontal, 4)

            bikeCalulatorView

            DurationPickerView(
                title: Localizables.PaceCalculator.transitionTime(transitionNumber: 2),
                mode: .compact,
                showHours: false,
                duration: $viewModel.t2Time
            )
            .padding(.horizontal, 4)

            secondRunCalculatorView
        }
    }

    var duathlonDistancePicker: some View {
        Menu {
            Button {
                selectedDuathlonDistance = nil
            } label: {
                Text(Localizables.PaceCalculator.race)
            }
            ForEach(DuathlonDistance.allCases, id: \.self) { distance in
                Button {
                    selectedDuathlonDistance = distance
                } label: {
                    Text(distance.displayName)
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Localizables.PaceCalculator.duathlonDistance)
                        .font(.Custom.Medium.font2)
                        .foregroundStyle(.secondary)
                    Text(selectedDuathlonDistance?.displayName ?? Localizables.PaceCalculator.race)
                        .font(.Custom.Regular.font3)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
            )
        }
        .buttonStyle(.plain)
    }

    var firstRunCalculatorView: some View {
        PaceTimeCalculatorView<RunningDistance>(
            sport: .run,
            viewModel: firstRunViewModel,
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
            viewModel: bikeViewModel,
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
            viewModel: secondRunViewModel,
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
        viewModel: DuathlonTimeViewModel(),
        firstRunViewModel: PaceCalculatorViewModel(
            paceCalculator: RunningPaceCalculator(),
            paceUnit: .minPerKm
        ),
        bikeViewModel: PaceCalculatorViewModel(
            paceCalculator: CyclingPaceCalculator(),
            paceUnit: .kmPerHour
        ),
        secondRunViewModel: PaceCalculatorViewModel(
            paceCalculator: RunningPaceCalculator(),
            paceUnit: .minPerKm
        ),
        selectedDuathlonDistance: .constant(nil)
    )
}
