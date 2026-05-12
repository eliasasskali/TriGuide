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
            Button {
                selectedTriDistance = nil
            } label: {
                Text(Localizables.PaceCalculator.race)
            }
            ForEach(TriathlonDistance.allCases, id: \.self) { distance in
                Button {
                    selectedTriDistance = distance
                } label: {
                    Text(distance.displayName)
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Localizables.PaceCalculator.triathlonDistance)
                        .font(.Custom.Medium.font2)
                        .foregroundStyle(.secondary)
                    Text(selectedTriDistance?.displayName ?? Localizables.PaceCalculator.race)
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
