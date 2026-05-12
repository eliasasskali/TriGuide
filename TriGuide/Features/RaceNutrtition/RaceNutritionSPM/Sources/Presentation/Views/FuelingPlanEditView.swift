//
// TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

struct FuelingPlanEditView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Dependencies

    @Binding var result: FuelingResult
    let onApplyChanges: ((FuelingResult) async -> Bool)?
    let showNameEditor: Bool
    private let analyticsService: FuelingPlanEditAnalyticsService
    private let calculationId: String?
    @State private var editableInstantEvents: [FuelingEvent]
    @State private var editableIntervalEvents: [FuelingEvent]
    @State private var liveHourlyBreakdown: [IntervalFueling]
    @State private var planName: String
    @State private var validationErrorMessage: String?

    // MARK: - Initializer

    init(
        result: Binding<TriGuideDomain.FuelingResult>,
        showNameEditor: Bool = false,
        analyticsService: FuelingPlanEditAnalyticsService = FuelingPlanEditAnalyticsServiceNoOp(),
        calculationId: String? = nil,
        onApplyChanges: ((FuelingResult) async -> Bool)? = nil
    ) {
        _result = result
        self.showNameEditor = showNameEditor
        self.analyticsService = analyticsService
        self.calculationId = calculationId
        self.onApplyChanges = onApplyChanges

        _editableInstantEvents = State(initialValue: result.wrappedValue.instantEvents)
        _editableIntervalEvents = State(initialValue: result.wrappedValue.intervalEvents)
        _liveHourlyBreakdown = State(initialValue: result.wrappedValue.hourlyBreakdown)
        _planName = State(initialValue: result.wrappedValue.name ?? "")
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if showNameEditor {
                    planNameEditor
                        .padding(.horizontal)
                }

                if !editableInstantEvents.isEmpty {
                    InstantEventsTimelineEditor(
                        duration: result.duration,
                        events: $editableInstantEvents
                    )
                    .padding(.horizontal)
                }

                if !editableIntervalEvents.isEmpty {
                    IntervalEventsTimelineEditor(
                        duration: result.duration,
                        events: $editableIntervalEvents
                    )
                    .padding(.horizontal)
                }

                breakdownView
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomActionBar
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
            planName = newResult.name ?? ""
        }
        .onAppear {
            recomputeLiveBreakdown()
            analyticsService.trackScreenView()
        }
        .errorAlert(message: $validationErrorMessage)
        .hideKeyboardOnTap()
    }
}

// MARK: - Private methods

private extension FuelingPlanEditView {
    var bottomActionBar: some View {
        actionButtons
            .padding()
            .frame(maxWidth: .infinity)
            .background(.bar)
            .overlay(alignment: .top) {
                Divider()
            }
    }

    var planNameEditor: some View {
        GroupBox {
            TextField(
                Localizables.RaceNutritionResults.savePlanNamePlaceholder,
                text: $planName
            )
        }
    }

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
        HStack(spacing: 12) {
            ActionButton(
                Localizables.RaceNutritionResults.editViewResetButtonLabel,
                isDisabled: !hasPendingChanges,
                accessibilityHint: Localizables.AccessibilityHints.tapTo(
                    Localizables.RaceNutritionResults.editViewResetButtonLabel
                ),
                action: resetToOriginal
            )
            .frame(maxWidth: .infinity)

            ActionButton(
                Localizables.RaceNutritionResults.editViewApplyButtonLabel,
                isDisabled: !hasPendingChanges,
                accessibilityHint: Localizables.AccessibilityHints.tapTo(
                    Localizables.RaceNutritionResults.editViewApplyButtonLabel
                ),
                action: {
                    Task {
                        await applyChanges()
                    }
                }
            )
            .frame(maxWidth: .infinity)
        }
    }

    var hasPendingChanges: Bool {
        let currentInstant = editableInstantEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let originalInstant = result.instantEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }

        let currentInterval = editableIntervalEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let originalInterval = result.intervalEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }

        let timelineChanged = currentInstant != originalInstant || currentInterval != originalInterval

        guard showNameEditor else { return timelineChanged }

        let currentName = planName.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalName = (result.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return timelineChanged || currentName != originalName
    }

    // MARK: - Action methods

    func resetToOriginal() {
        editableInstantEvents = result.instantEvents
        editableIntervalEvents = result.intervalEvents
        planName = result.name ?? ""
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

    func applyChanges() async {
        let current = result
        let trimmedName = planName.trimmingCharacters(in: .whitespacesAndNewlines)

        if showNameEditor, trimmedName.isEmpty {
            validationErrorMessage = Localizables.FormErrors.requiredField
            return
        }

        let sortedInstantEvents = editableInstantEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let sortedIntervalEvents = editableIntervalEvents.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero }
        let newTimeLine = sortedInstantEvents + sortedIntervalEvents
        let newHourlyBreakdown = LocalFuelingCalculator.computeBreakDown(
            totalDuration: current.duration,
            events: newTimeLine
        )
        let updated = FuelingResult(
            name: showNameEditor ? trimmedName : current.name,
            timeLine: newTimeLine,
            totalCarbsTarget: current.totalCarbsTarget,
            duration: current.duration,
            selectedItems: current.selectedItems,
            hourlyBreakdown: newHourlyBreakdown
        )

        if let onApplyChanges {
            let success = await onApplyChanges(updated)
            guard success else { return }
        }

        analyticsService.trackPlanEdited(
            data: FuelingPlanEditAnalyticsData(original: current, edited: updated, calculationId: calculationId)
        )

        result = updated
        liveHourlyBreakdown = newHourlyBreakdown

        dismiss()
    }
}
