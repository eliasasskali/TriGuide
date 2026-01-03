//
// TriGuide 2025
//

import SwiftUI
import DesignSystem
import TriGuideDomain

struct FuelingPlanFullView: View {
    @Binding var result: FuelingResult

    @State private var editableInstantEvents: [FuelingEvent]
    @State private var editableIntervalEvents: [FuelingEvent]

    init(result: Binding<TriGuideDomain.FuelingResult>) {
        _result = result

        _editableInstantEvents = State(initialValue: result.wrappedValue.instantEvents)
        _editableIntervalEvents = State(initialValue: result.wrappedValue.intervalEvents)
    }

    var body: some View {
        VStack {
            // TODO: Pass the instant items to the editor as a binding so we can update the result when we press apply changes
            InstantEventsTimelineEditor(
                duration: result.duration,
                events: $editableInstantEvents
            )

            // TODO: Pass the interval items to the editor as a binding so we can update the result when we press apply changes
//            IntervalEventsTimelineEditor(
//                duration: result.duration,
//                events: $editableIntervalEvents
//            )

            HStack(spacing: 12) {
                ActionButton.init("Reset", action: resetToOriginal)

                ActionButton.init("Apply changes", action: applyChanges)
            }
        }
    }
}

// MARK: - Private methods

private extension FuelingPlanFullView {
    func resetToOriginal() {
        editableInstantEvents = result.instantEvents
        editableIntervalEvents = result.intervalEvents
    }

    func applyChanges() {
        let newTimeLine = editableInstantEvents + editableIntervalEvents

        let current = result
        let updated = FuelingResult(
            name: current.name,
            timeLine: newTimeLine,
            totalCarbsTarget: current.totalCarbsTarget,
            duration: current.duration,
            selectedItems: current.selectedItems,
            hourlyBreakdown: current.hourlyBreakdown // TODO: Recalculate hourly breakdown
        )

        result = updated
    }
}
