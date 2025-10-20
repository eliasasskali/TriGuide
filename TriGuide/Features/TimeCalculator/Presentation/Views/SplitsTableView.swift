//
//  TriGuide 2025
//

import SwiftUI
import Localization

struct SplitsTableView: View {
    @Binding var totalDistance: Double
    @Binding var pace: TimeInterval
    @Binding var paceUnit: SupportedUnit
    
    @State var splitsDistance: Double
    @State private var pickerDistanceUnit: DistanceUnit

    @ObservedObject private var viewModel: SplitsTableViewModel
    
    init(
        totalDistance: Binding<Double>,
        pace: Binding<TimeInterval>,
        paceUnit: Binding<SupportedUnit>,
        splitsDistance: Double? = nil,
        viewModel: SplitsTableViewModel
    ) {
        self._totalDistance = totalDistance
        self._pace = pace
        self._paceUnit = paceUnit
        self.splitsDistance = splitsDistance ?? paceUnit.wrappedValue.defaultSplitsDistance
        self.pickerDistanceUnit = paceUnit.wrappedValue.distanceUnit
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 16) {
            topBar
            
            splitsGrid
        }
        .padding()
        .cardBackground()
        .padding(4)
        .onAppear { updateSplits() }
        .onChange(of: totalDistance) { updateSplits() }
        .onChange(of: pace) { updateSplits() }
        .onChange(of: paceUnit) { updateSplits() }
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
        splitsDistance: 5000,
        viewModel: SplitsTableViewModel(paceCalculator: RunningPaceCalculator())
    )
}
