//
//  TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

struct TriathlonTimeView: View {
    @ObservedObject var viewModel: TriathlonTimeViewModel
    @ObservedObject var swimViewModel: PaceCalculatorViewModel
    @ObservedObject var bikeViewModel: PaceCalculatorViewModel
    @ObservedObject var runViewModel: PaceCalculatorViewModel

    @Binding var selectedTriDistance: TriathlonDistance?

    var body: some View {
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

private extension TriathlonTimeView {
    var calculatorViews: some View {
        VStack(spacing: 16) {
            triDistancePicker

            swimCalculatorView

            DurationPickerView(
                title: Localizables.PaceCalculator.transitionTime(transitionNumber: 1),
                mode: .compact,
                showHours: false,
                duration: $viewModel.t1Time
            )
            .padding(.horizontal, 4)

            bikeCalculatorView

            DurationPickerView(
                title: Localizables.PaceCalculator.transitionTime(transitionNumber: 2),
                mode: .compact,
                showHours: false,
                duration: $viewModel.t2Time
            )
            .padding(.horizontal, 4)

            runCalculatorView
        }
    }

    var triDistancePicker: some View {
        Menu {
            Picker(Localizables.PaceCalculator.triathlonDistance, selection: $selectedTriDistance) {
                Text(Localizables.PaceCalculator.race).tag(nil as TriathlonDistance?)
                ForEach(TriathlonDistance.allCases, id: \.self) { distance in
                    Text(distance.displayName).tag(Optional(distance))
                }
            }
        } label: {
            HStack {
                Text(Localizables.PaceCalculator.triathlonDistance)
                    .font(.Custom.Medium.font4)
                    .foregroundStyle(.primary)
                Text(selectedTriDistance?.displayName ?? Localizables.PaceCalculator.race)
                    .font(.Custom.Regular.font4)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .tint(.primary)
    }

    var swimCalculatorView: some View {
        PaceTimeCalculatorView<SwimmingDistance>(
            sport: .swim,
            viewModel: swimViewModel,
            selectedRaceDistance: Binding(
                get: { selectedTriDistance?.swimmingDistance },
                set: { _ in
                    selectedTriDistance = nil
                }
            ),
            duration: $viewModel.swimTime
        )
    }

    var bikeCalculatorView: some View {
        PaceTimeCalculatorView<CyclingDistance>(
            sport: .bike,
            viewModel: bikeViewModel,
            selectedRaceDistance: Binding(
                get: { selectedTriDistance?.cyclingDistance },
                set: { _ in
                    selectedTriDistance = nil
                }
            ),
            duration: $viewModel.cyclingTime
        )
    }

    var runCalculatorView: some View {
        PaceTimeCalculatorView<RunningDistance>(
            sport: .run,
            viewModel: runViewModel,
            selectedRaceDistance: Binding(
                get: { selectedTriDistance?.runningDistance },
                set: { _ in
                    selectedTriDistance = nil
                }
            ),
            duration: $viewModel.runningTime
        )
    }
}

#Preview {
    TriathlonTimeView(
        viewModel: TriathlonTimeViewModel(),
        swimViewModel: PaceCalculatorViewModel(
            paceCalculator: SwimmingPaceCalculator(),
            paceUnit: .minPer100m
        ),
        bikeViewModel: PaceCalculatorViewModel(
            paceCalculator: CyclingPaceCalculator(),
            paceUnit: .kmPerHour
        ),
        runViewModel: PaceCalculatorViewModel(
            paceCalculator: RunningPaceCalculator(),
            paceUnit: .minPerKm
        ),
        selectedTriDistance: .constant(nil)
    )
}
