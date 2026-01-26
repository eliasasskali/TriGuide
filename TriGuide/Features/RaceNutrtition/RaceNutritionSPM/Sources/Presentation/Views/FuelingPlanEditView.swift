//
// TriGuide 2025
//

import SwiftUI
import DesignSystem
import TriGuideDomain
import Localization

struct FuelingPlanEditView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Dependencies

    @Binding var result: FuelingResult
    @State private var editableInstantEvents: [FuelingEvent]
    @State private var editableIntervalEvents: [FuelingEvent]
    @State private var liveHourlyBreakdown: [IntervalFueling]

    // MARK: - Initializer

    init(result: Binding<TriGuideDomain.FuelingResult>) {
        _result = result

        _editableInstantEvents = State(initialValue: result.wrappedValue.instantEvents)
        _editableIntervalEvents = State(initialValue: result.wrappedValue.intervalEvents)
        _liveHourlyBreakdown = State(initialValue: result.wrappedValue.hourlyBreakdown)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if !editableInstantEvents.isEmpty {
                    InstantEventsTimelineEditor(
                        duration: result.duration,
                        events: $editableInstantEvents
                    )
                }

                if !editableIntervalEvents.isEmpty {
                    IntervalEventsTimelineEditor(
                        duration: result.duration,
                        events: $editableIntervalEvents
                    )
                }

                breakdownView
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            actionButtons
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

private extension FuelingPlanEditView {
    var breakdownView: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Text(Localizables.RaceNutritionResults.editViewHourlyBreakdownTitle)
                    .font(.Custom.Medium.font5)

                IntervalBreakdownView(breakdown: liveHourlyBreakdown)
            }
        }
    }

    var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ActionButton(
                    Localizables.RaceNutritionResults.editViewResetButtonLabel,
                    accessibilityHint: Localizables.AccessibilityHints.tapTo(
                        Localizables.RaceNutritionResults.editViewResetButtonLabel
                    ),
                    action: resetToOriginal
                )
                .frame(maxWidth: .infinity)

                ActionButton(
                    Localizables.RaceNutritionResults.editViewApplyButtonLabel,
                    accessibilityHint: Localizables.AccessibilityHints.tapTo(
                        Localizables.RaceNutritionResults.editViewApplyButtonLabel
                    ),
                    action: applyChanges
                )
                .frame(maxWidth: .infinity)
            }
            .padding(8)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Action methods

    func resetToOriginal() {
        editableInstantEvents = result.instantEvents
        editableIntervalEvents = result.intervalEvents
        recomputeLiveBreakdown()
    }

    func recomputeLiveBreakdown() {
        let timeline = (editableInstantEvents + editableIntervalEvents)
            .sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }

        liveHourlyBreakdown = LocalFuelingCalculator.computeBreakDown(
            totalDuration: result.duration,
            events: timeline
        )
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
