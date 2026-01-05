//
// TriGuide 2025
//

import SwiftUI
import DesignSystem
import TriGuideDomain

struct FuelingPlanFullView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var result: FuelingResult

    @State private var editableInstantEvents: [FuelingEvent]
    @State private var editableIntervalEvents: [FuelingEvent]
    @State private var liveHourlyBreakdown: [IntervalFueling]

    init(result: Binding<TriGuideDomain.FuelingResult>) {
        _result = result

        _editableInstantEvents = State(initialValue: result.wrappedValue.instantEvents)
        _editableIntervalEvents = State(initialValue: result.wrappedValue.intervalEvents)
        _liveHourlyBreakdown = State(initialValue: result.wrappedValue.hourlyBreakdown)
    }

    var body: some View {

        VStack {
            ScrollView {
                VStack {
                    InstantEventsTimelineEditor(
                        duration: result.duration,
                        events: $editableInstantEvents
                    )

                    IntervalEventsTimelineEditor(
                        duration: result.duration,
                        events: $editableIntervalEvents
                    )

                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Hourly breakdown:")
                                .font(.Custom.Medium.font5)

                            TimeBreakdownView(breakdown: liveHourlyBreakdown)
                        }
                    }

                    Spacer()
                }
            }
            HStack(spacing: 12) {
                ActionButton.init("Reset", action: resetToOriginal)

                ActionButton.init("Apply changes", action: applyChanges)
            }
        }
        .onChange(of: editableInstantEvents) {
            recomputeLiveBreakdown()
        }
        .onChange(of: editableIntervalEvents) {
            recomputeLiveBreakdown()
        }
        .onChange(of: result) { _, newResult in
            editableInstantEvents = newResult.instantEvents
            editableIntervalEvents = newResult.intervalEvents
            liveHourlyBreakdown = newResult.hourlyBreakdown
        }
        .onAppear {
            recomputeLiveBreakdown()
        }
    }
}

// MARK: - Private methods

private extension FuelingPlanFullView {
    func resetToOriginal() {
        editableInstantEvents = result.instantEvents
        editableIntervalEvents = result.intervalEvents
        recomputeLiveBreakdown()
    }

    func recomputeLiveBreakdown() {
        let sortedInstantEvents = editableInstantEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let sortedIntervalEvents = editableIntervalEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let newTimeLine = sortedInstantEvents + sortedIntervalEvents

        let breakdown = LocalFuelingCalculator.computeBreakDown(
            totalDuration: result.duration,
            events: newTimeLine
        )

        liveHourlyBreakdown = breakdown
    }

    func applyChanges() {
        let current = result

        let sortedInstantEvents = editableInstantEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let sortedIntervalEvents = editableIntervalEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let newTimeLine = sortedInstantEvents + sortedIntervalEvents
        let newHourlyBreakdown = LocalFuelingCalculator.computeBreakDown(
            totalDuration: current.duration,
            events: newTimeLine
        )
        let updated = FuelingResult(
            name: current.name,
            timeLine: newTimeLine,
            totalCarbsTarget: current.totalCarbsTarget,
            duration: current.duration,
            selectedItems: current.selectedItems,
            hourlyBreakdown: newHourlyBreakdown
        )

        result = updated
        liveHourlyBreakdown = newHourlyBreakdown

        dismiss()
    }
}
