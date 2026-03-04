//
// TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

public struct RaceNutritionResultView: View {
    // MARK: - Dependencies

    @ObservedObject private var coordinator: RaceNutritionCoordinator
    @ObservedObject private var viewModel: RaceNutritionResultViewModel
    @Binding var fuelingResult: FuelingResult
    private let showSaveButton: Bool

    // MARK: - Properties

    @State private var shouldShowSelectedItems = false
    @State private var showSavedSuccessfullyToast = false
    @State private var showPlanNameDialog = false
    @State private var planName = ""
    @State private var isSavingPlan = false
    @State private var lastSavedFuelingResult: FuelingResult?

    // MARK: - Computed properties

    var roundedTimeLine: [FuelingEvent] {
        fuelingResult.timeLine.map { event in
            let consumption = switch event.consumption {
            case let .instant(time):
                FuelingEvent.Consumption.instant(time: time.roundToMultiple(rule: .down))
            case let .interval(startTime, endTime):
                FuelingEvent.Consumption.interval(
                    start: startTime.roundToMultiple(rule: .down),
                    end: endTime.roundToMultiple(rule: .up)
                )
            }

            return FuelingEvent(consumption: consumption, carbItem: event.carbItem)
        }
    }

    var itemTimeLine: [FuelingEvent] {
        roundedTimeLine.filter { event in
            switch event.carbItem.type {
            case .drink:
                return false
            default:
                return true
            }
        }
    }

    var drinkTimeLine: [FuelingEvent] {
        roundedTimeLine.filter { event in
            switch event.carbItem.type {
            case .drink:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Initializer

    public init(
        coordinator: RaceNutritionCoordinator,
        viewModel: RaceNutritionResultViewModel,
        shouldShowSelectedItems: Bool = false,
        showSaveButton: Bool = true,
        fuelingResult: Binding<FuelingResult>
    ) {
        _coordinator = ObservedObject(wrappedValue: coordinator)
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _shouldShowSelectedItems = State(initialValue: shouldShowSelectedItems)
        self.showSaveButton = showSaveButton
        _fuelingResult = fuelingResult
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                planSummary
                selectedItems
                fuelingPlan
                hourlyBreakdown
            }
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showSaveButton {
                bottomSaveBar
            }
        }
        .errorAlert(
            message: Binding(
                get: { viewModel.errorMessage },
                set: { viewModel.errorMessage = $0 }
            )
        )
        .toast(
            isPresented: $showSavedSuccessfullyToast,
            message: Localizables.RaceNutritionResults.saveSuccessToastMessage
        )
        .alert(
            Localizables.RaceNutritionResults.savePlanButtonLabel,
            isPresented: $showPlanNameDialog
        ) {
            TextField(
                Localizables.RaceNutritionResults.savePlanNamePlaceholder,
                text: $planName
            )

            Button(Localizables.Common.cancel, role: .cancel) {
                showPlanNameDialog = false
            }

            Button(Localizables.Common.save) {
                Task {
                    let trimmedName = planName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedName.isEmpty else {
                        viewModel.errorMessage = Localizables.FormErrors.requiredField
                        return
                    }

                    isSavingPlan = true
                    defer { isSavingPlan = false }

                    let savedSuccessfully =
                        await viewModel.saveFuelingPlan(
                            fuelingResult,
                            planName: trimmedName
                        )
                    showSavedSuccessfullyToast = savedSuccessfully
                    if savedSuccessfully {
                        lastSavedFuelingResult = fuelingResult
                    }
                    planName = ""
                }
            }
            .accessibilityHint(Localizables.AccessibilityHints.tapTo(Localizables.RaceNutritionResults.savePlanButtonHint))
        }
        .navigationTitle(screenTitle)
    }
}

// MARK: - Private methods

private extension RaceNutritionResultView {
    var screenTitle: String {
        let trimmedName = fuelingResult.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedName.isEmpty ? Localizables.RaceNutritionResults.fuelingPlanTitle : trimmedName
    }

    var isPlanDirty: Bool {
        guard let lastSavedFuelingResult else { return true }
        return fuelingResult != lastSavedFuelingResult
    }

    var isSaveButtonDisabled: Bool {
        isSavingPlan || !isPlanDirty
    }

    var saveButtonTitle: String {
        if isSavingPlan {
            return Localizables.AccessibilityHints.loading
        }

        if !isPlanDirty {
            return Localizables.RaceNutritionResults.saveSuccessToastMessage
        }

        return Localizables.RaceNutritionResults.savePlanButtonLabel
    }

    @ViewBuilder
    var fuelingPlan: some View {
        GroupBox {
            VStack(spacing: 16) {
                HStack {
                    Text(Localizables.RaceNutritionResults.fuelingPlanTitle)
                        .font(.Custom.Medium.font5)

                    Spacer()

                    HStack(alignment: .center) {
                        Text(Localizables.RaceNutritionResults.fuelingPlanEditButtonLabel)
                            .font(.Custom.Regular.font3)
                        Image(systemName: "pencil")
                            .fixedSize()
                            .bold()
                    }
                    .onTapGesture {
                        coordinator.pushFuelingPlanFullView()
                    }
                }

                if !itemTimeLine.isEmpty {
                    Grid {
                        GridRow {
                            Text(Localizables.RaceNutritionResults.fuelingPlanTimeColumnTitle)
                            Text(Localizables.RaceNutritionResults.fuelingPlanItemColumnTitle)
                        }
                        .font(.Custom.Medium.font3)

                        Divider()

                        ForEach(itemTimeLine, id: \.self) { event in
                            GridRow {
                                switch event.consumption {
                                case let .instant(time):
                                    Text("\(time.formattedAsHourMinSec)")
                                        .font(.Custom.Regular.font3)

                                case let .interval(startTime, endTime):
                                    Text("\(startTime.formattedAsHourMinSec) - \(endTime.formattedAsHourMinSec)")
                                        .font(.Custom.Regular.font3)
                                }

                                Text("\(event.carbItem.name)")
                                    .font(.Custom.Regular.font3)
                            }
                            .padding(.vertical, 4)

                            if event != itemTimeLine.last {
                                Divider()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if !drinkTimeLine.isEmpty {
                    Grid {
                        GridRow {
                            Text(Localizables.RaceNutritionResults.fuelingPlanIntervalColumnTitle)
                            Text(Localizables.RaceNutritionResults.fuelingPlanDrinkColumnTitle)
                        }
                        .font(.Custom.Medium.font3)

                        Divider()

                        ForEach(drinkTimeLine, id: \.self) { event in
                            GridRow {
                                switch event.consumption {
                                case let .instant(time):
                                    Text("\(time.formattedAsHourMinSec)")
                                        .font(.Custom.Regular.font3)

                                case let .interval(startTime, endTime):
                                    Text("\(startTime.formattedAsHourMinSec) - \(endTime.formattedAsHourMinSec)")
                                        .font(.Custom.Regular.font3)
                                }

                                Text("\(event.carbItem.name)")
                                    .font(.Custom.Regular.font3)
                            }
                            .padding(.vertical, 4)

                            if event != drinkTimeLine.last {
                                Divider()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var planSummary: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(Localizables.RaceNutritionResults.fuelingPlanSelectedCarbsTargetLabel)
                        .font(.Custom.Medium.font3)
                    Spacer()
                    Text("\(Int(fuelingResult.totalSelectedCarbs))/\(Int(fuelingResult.totalCarbsTarget)) g")
                        .font(.Custom.Regular.font3)
                }

                HStack {
                    Text(Localizables.RaceNutritionResults.fuelingPlanSelectedCarbsHourTargetLabel)
                        .font(.Custom.Medium.font3)
                    Spacer()
                    Text("\(Int(fuelingResult.actualCarbsPerHour))/\(Int(fuelingResult.carbTargetPerHour)) g")
                        .font(.Custom.Regular.font3)
                }
            }
        }
    }

    @ViewBuilder
    var selectedItems: some View {
        if shouldShowSelectedItems {
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    selectedItemsHeader

                    ForEach(fuelingResult.selectedItems) { selection in
                        Text("\(Int(selection.quantity))x \(selection.item.name) (\(Int(selection.item.gramsOfCarbs)) g)")
                            .font(.Custom.Regular.font3)
                            .lineLimit(1)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            GroupBox {
                selectedItemsHeader
            }
        }
    }

    var selectedItemsHeader: some View {
        HStack {
            Text(Localizables.RaceNutritionResults.fuelingPlanSelectedNutritionItemsTitle)
                .font(shouldShowSelectedItems ? .Custom.Medium.font4 : .Custom.Medium.font3)

            Spacer()

            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(shouldShowSelectedItems ? 180 : 0))
                .animation(.easeInOut, value: shouldShowSelectedItems)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            shouldShowSelectedItems.toggle()
        }
    }

    var hourlyBreakdown: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Text(Localizables.RaceNutritionResults.fuelingPlanHourlyBreakdownTitle)
                    .font(.Custom.Medium.font5)

                IntervalBreakdownView(breakdown: fuelingResult.hourlyBreakdown)
            }
        }
    }

    @ViewBuilder
    var saveButton: some View {
        ActionButton(
            saveButtonTitle,
            isLoading: isSavingPlan,
            isDisabled: isSaveButtonDisabled,
            accessibilityHint: Localizables.AccessibilityHints.tapTo(
                Localizables.RaceNutritionResults.savePlanButtonHint
            ),
            action: {
                showPlanNameDialog = true
            }
        )
    }

    var bottomSaveBar: some View {
        saveButton
            .padding()
            .frame(maxWidth: .infinity)
            .background(.bar)
            .overlay(alignment: .top) {
                Divider()
            }
    }
}

#Preview {
    RaceNutritionResultView(
        coordinator: RaceNutritionCoordinator(
            factory: RaceNutritionViewFactoryDefault(dependencies: .init())
        ),
        viewModel: RaceNutritionResultViewModel(
            saveFuelingPlanUseCase: SaveFuelingPlanUseCaseDefault(
                repository: NutritionPlansRepositoryDefault(
                    nutritionPlansDataSource: try! StoredNutritionPlansDataSourceDefault()
                )
            ),
            deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCaseDefault(
                repository: NutritionPlansRepositoryDefault(
                    nutritionPlansDataSource: try! StoredNutritionPlansDataSourceDefault()
                )
            )
        ),
        fuelingResult: .constant(
            .init(
                timeLine: [
                    FuelingEvent(consumption: .instant(time: TimeInterval(7200 / 5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                    FuelingEvent(consumption: .instant(time: TimeInterval(7200 * 2 / 5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                    FuelingEvent(consumption: .instant(time: TimeInterval(7200 * 3 / 5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                    FuelingEvent(consumption: .instant(time: TimeInterval(7200 * 4 / 5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                ],
                totalCarbsTarget: 180,
                duration: 7200,
                selectedItems: [
                    CarbItemSelection(item: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel), quantity: 4),
                    CarbItemSelection(item: .init(id: "id2", name: "Long text that should fit in a line", gramsOfCarbs: 45, type: .gel), quantity: 4),
                ],
                hourlyBreakdown: [
                    IntervalFueling(duration: 3600, hourIndex: 0, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                    IntervalFueling(duration: 3600, hourIndex: 1, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                    IntervalFueling(duration: 3600, hourIndex: 2, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                    IntervalFueling(duration: 3600, hourIndex: 3, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                    IntervalFueling(duration: 3600, hourIndex: 4, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                ]
            )
        )
    )
}
