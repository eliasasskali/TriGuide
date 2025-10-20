//
//  TriGuide 2025
//

import SwiftUI
import Localization

struct PaceTimeCalculatorView<Distance: RaceDistance & CaseIterable>: View where Distance.AllCases: RandomAccessCollection {
    let sport: SupportedSport
    @StateObject var viewModel: PaceCalculatorViewModel

    var selectedRaceDistance: Binding<Distance?>? = nil
    var duration: Binding<TimeInterval?>? = nil

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: sport.representativeIcon)
                    .font(.Custom.Regular.font5)
                    .foregroundColor(.black)

                distancePicker
                raceDistancePicker
            }

            HStack {
                DurationPickerView(
                    title: Localizables.PaceCalculator.time,
                    duration: $viewModel.duration
                )

                paceSpeedPicker
                unitsPicker
            }
        }
        .onAppear {
            if viewModel.paceUnit == nil {
                viewModel.paceUnit = sport.supportedUnits.first
            }
            if let externalDuration = duration?.wrappedValue {
                viewModel.duration = externalDuration
            }
        }
        .onChange(of: viewModel.duration) { _, newValue in
            duration?.wrappedValue = newValue
        }
        .onChange(of: selectedRaceDistance?.wrappedValue) { _, newValue in
            viewModel.distance = newValue?.meters
        }
        .padding()
        .cardBackground()
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }
}

private extension PaceTimeCalculatorView {
    @ViewBuilder
    var distancePicker: some View {
        DistancePickerView(
            title: Localizables.PaceCalculator.distance,
            distance: $viewModel.distance,
            unit: .constant(sport.defaultDistanceUnit)
        ) {
            selectedRaceDistance?.wrappedValue = nil
        }
    }

    @ViewBuilder
    var paceSpeedPicker: some View {
        if sport == .bike {
            DecimalPickerView(
                title: Localizables.PaceCalculator.speed,
                value: Binding(
                    get: { viewModel.speed },
                    set: { viewModel.speed = $0 }
                ),
                range: 0...60,
                unit: viewModel.paceUnit?.localized,
                showUnitOnLabel: false,
                mode: .regular
            )
        } else {
            DurationPickerView(
                title: Localizables.PaceCalculator.pace,
                showHours: (viewModel.pace ?? 0) >= 3600,
                duration: $viewModel.pace
            )
        }
    }

    @ViewBuilder
    var unitsPicker: some View {
        Menu {
            ForEach(sport.supportedUnits, id: \.self) { unit in
                Button {
                    viewModel.paceUnit = unit
                } label: {
                    Text(unit.localized)
                        .font(.Custom.Regular.font3) // menu item font
                }
            }
        } label: {
            HStack {
                Text(viewModel.paceUnit?.localized ?? Localizables.PaceCalculator.unit)
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.Custom.Regular.font3) // label font
        }
    }

    @ViewBuilder
    var raceDistancePicker: some View {
        Menu {
            ForEach(Distance.allCases, id: \.self) { distance in
                Button {
                    selectedRaceDistance?.wrappedValue = distance
                    viewModel.distance = distance.meters
                } label: {
                    Text(distance.displayName)
                        .font(.Custom.Regular.font3)
                }
            }
        } label: {
            HStack {
                Text(selectedRaceDistance?.wrappedValue?.displayName ?? Localizables.PaceCalculator.race)
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.Custom.Regular.font3)
        }
    }
}

#Preview {
    PaceTimeCalculatorView<RunningDistance>(
        sport: .run,
        viewModel: PaceCalculatorViewModel(paceCalculator: RunningPaceCalculator()),
        duration: .constant(60)
    )
}
