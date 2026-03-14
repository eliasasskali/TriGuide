//
//  TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

struct SplitsTableView: View {
    @Binding var totalDistance: Double
    @Binding var pace: TimeInterval
    @Binding var paceUnit: SpeedUnit
    @Binding var splitsDistance: Double

    @State private var pickerDistanceUnit: DistanceUnit

    @ObservedObject private var viewModel: SplitsTableViewModel

    init(
        totalDistance: Binding<Double>,
        pace: Binding<TimeInterval>,
        paceUnit: Binding<SpeedUnit>,
        splitsDistance: Binding<Double>,
        viewModel: SplitsTableViewModel
    ) {
        _totalDistance = totalDistance
        _pace = pace
        _paceUnit = paceUnit
        _splitsDistance = splitsDistance
        pickerDistanceUnit = paceUnit.wrappedValue.distanceUnit
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            topBar

            splitsGrid
        }
        .cardBackground()
        .padding(4)
        .onAppear { updateSplits() }
        .onChange(of: totalDistance) { updateSplits() }
        .onChange(of: pace) { updateSplits() }
        .onChange(of: paceUnit) {
            pickerDistanceUnit = paceUnit.distanceUnit
            updateSplits()
        }
    }
}

// MARK: - Views

private extension SplitsTableView {
    var topBar: some View {
        HStack {
            Text(Localizables.SplitsTable.tableTitle)
                .font(.Custom.Medium.font4)

            Spacer()

            distancePicker
                .fixedSize()
        }
    }

    var distancePicker: some View {
        DistancePickerView(
            title: Localizables.SplitsTable.byDistance,
            distance: Binding<Double?>(
                get: { splitsDistance },
                set: { splitsDistance = $0 ?? splitsDistance }
            ),
            unit: $pickerDistanceUnit
        ) {
            viewModel.updateSplits(
                splitsDistance: splitsDistance,
                totalDistance: totalDistance,
                pace: pace,
                paceUnit: paceUnit
            )
        }
    }

    @ViewBuilder
    var splitsGrid: some View {
        if splitsDistance > 0 {
            Grid {
                GridRow {
                    Text(Localizables.SplitsTable.columnNameDistance)
                    Text(Localizables.SplitsTable.columnNameSplitTime)
                    Text(Localizables.SplitsTable.columnNameCumulativeTime)
                }
                .font(.Custom.Medium.font3)

                Divider()

                ForEach(viewModel.splits, id: \.distance) { split in
                    GridRow {
                        Text(split.formattedDistance(with: pickerDistanceUnit))
                        Text(split.splitTime.formattedAsHourMinSec)
                        Text(split.cumulativeTime.formattedAsHourMinSec)
                    }
                    .font(.Custom.Regular.font3)

                    if split != viewModel.splits.last {
                        Divider()
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

// MARK: - Private methods

private extension SplitsTableView {
    func updateSplits() {
        viewModel.updateSplits(
            splitsDistance: splitsDistance,
            totalDistance: totalDistance,
            pace: pace,
            paceUnit: paceUnit
        )
    }
}

#Preview {
    SplitsTableView(
        totalDistance: .constant(21000),
        pace: .constant(270),
        paceUnit: .constant(.minPerKm),
        splitsDistance: .constant(5000),
        viewModel: SplitsTableViewModel(paceCalculator: RunningPaceCalculator())
    )
}
