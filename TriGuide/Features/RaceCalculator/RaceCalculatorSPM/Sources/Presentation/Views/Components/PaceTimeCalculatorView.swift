//
//  TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

public struct PaceTimeCalculatorView<Distance: RaceDistance & CaseIterable>: View where Distance.AllCases: RandomAccessCollection {
    let sport: SupportedSport
    @StateObject var viewModel: PaceCalculatorViewModel
    @State private var localSelectedRace: Distance?

    var selectedRaceDistance: Binding<Distance?>?
    var duration: Binding<TimeInterval?>?

    public init(
        sport: SupportedSport,
        viewModel: PaceCalculatorViewModel,
        selectedRaceDistance: Binding<Distance?>? = nil,
        duration: Binding<TimeInterval?>? = nil
    ) {
        self.sport = sport
        _viewModel = StateObject(wrappedValue: viewModel)
        self.selectedRaceDistance = selectedRaceDistance
        self.duration = duration
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: sport.representativeIcon)
                    .font(.Custom.Regular.font5)
                    .foregroundStyle(.primary)

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
        .onChange(of: viewModel.distance) { _, newValue in
            if newValue == nil {
                localSelectedRace = nil
            }
        }
        .onChange(of: selectedRaceDistance?.wrappedValue) { _, newValue in
            localSelectedRace = newValue
            guard let newValue else { return }
            viewModel.distance = newValue.meters
        }
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
            unit: Binding<DistanceUnit>(
                get: { viewModel.distanceUnit ?? sport.defaultDistanceUnit },
                set: { viewModel.distanceUnit = $0 }
            )
        ) {
            localSelectedRace = nil
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
                        .font(.Custom.Regular.font3)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.paceUnit?.localized ?? Localizables.PaceCalculator.unit)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
            .font(.Custom.Regular.font2)
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(UIColor.lightGray).opacity(0.2))
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var raceDistancePicker: some View {
        Menu {
            ForEach(Distance.allCases, id: \.self) { distance in
                Button {
                    localSelectedRace = distance
                    selectedRaceDistance?.wrappedValue = distance
                    viewModel.distance = distance.meters
                } label: {
                    Text(distance.displayName)
                        .font(.Custom.Regular.font3)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(localSelectedRace?.displayName ?? Localizables.PaceCalculator.race)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
            .font(.Custom.Regular.font2)
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(UIColor.lightGray).opacity(0.2))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaceTimeCalculatorView<RunningDistance>(
        sport: .run,
        viewModel: PaceCalculatorViewModel(paceCalculator: RunningPaceCalculator()),
        duration: .constant(60)
    )
}
