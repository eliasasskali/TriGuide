//
//  TriGuide 2025
//

import SwiftUI
import Localization
import DesignSystem

struct TriathlonTimeView: View {
    @StateObject var viewModel: TriathlonTimeViewModel

    @State var selectedTriDistance: TriathlonDistance? = nil

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
                labelsBackgroundColor: Color.Primary.white,
                duration: $viewModel.t1Time
            )
            .padding(.horizontal, 4)

            bikeCalculatorView

            DurationPickerView(
                title: Localizables.PaceCalculator.transitionTime(transitionNumber: 2),
                mode: .compact,
                labelsBackgroundColor: Color.Primary.white,
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
                    .foregroundStyle(.black)
                Text(selectedTriDistance?.displayName ?? Localizables.PaceCalculator.race)
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

    var swimCalculatorView: some View {
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
    }

    var bikeCalculatorView: some View {
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
    }

    var runCalculatorView: some View {
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
    }
}

#Preview {
    TriathlonTimeView(
        viewModel: TriathlonTimeViewModel()
    )
}
