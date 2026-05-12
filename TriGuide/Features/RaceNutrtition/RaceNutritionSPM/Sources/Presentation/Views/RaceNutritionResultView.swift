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
    private let analyticsService: RaceNutritionResultAnalyticsService
    private let showSaveButton: Bool

    // MARK: - Properties

    @State private var shouldShowSelectedItems = false
    @State private var showSavedSuccessfullyToast = false
    @State private var showPlanNameDialog = false
    @State private var errorAlertMessage: String?
    @State private var planName = ""
    @State private var isSavingPlan = false
    @State private var wasEdited = false
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

    var sortedTimeLine: [FuelingEvent] {
        roundedTimeLine.sorted { $0.consumptionTimeOrZero < $1.consumptionTimeOrZero
        }
    }

    // MARK: - Initializer

    public init(
        coordinator: RaceNutritionCoordinator,
        viewModel: RaceNutritionResultViewModel,
        analyticsService: RaceNutritionResultAnalyticsService = RaceNutritionResultAnalyticsServiceNoOp(),
        shouldShowSelectedItems: Bool = false,
        showSaveButton: Bool = true,
        fuelingResult: Binding<FuelingResult>
    ) {
        _coordinator = ObservedObject(wrappedValue: coordinator)
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.analyticsService = analyticsService
        _shouldShowSelectedItems = State(initialValue: shouldShowSelectedItems)
        self.showSaveButton = showSaveButton
        _fuelingResult = fuelingResult
    }

    // MARK: - Body

    public var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: 16) {
                    fuelingPlan
                    hourlyBreakdown
                    selectedItems
                        .id("selectedItems")
                }
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            .onChange(of: shouldShowSelectedItems) { _, isExpanded in
                guard isExpanded else { return }
                withAnimation {
                    scrollProxy.scrollTo("selectedItems", anchor: .top)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if showSaveButton {
                    bottomSaveBar
                }
            }
        }
        .floatingActionButton(
            Localizables.RaceNutritionResults.fuelingPlanEditButtonLabel,
            systemImage: "pencil",
            bottomPadding: showSaveButton ? 100 : 20
        ) {
            analyticsService.trackEditPlanClick()
            wasEdited = true
            coordinator.pushFuelingPlanFullView()
        }
        .toast(
            isPresented: $showSavedSuccessfullyToast,
            message: Localizables.RaceNutritionResults.saveSuccessToastMessage
        )
        .alert(
            alertTitle,
            isPresented: isAlertPresented
        ) {
            if errorAlertMessage == nil {
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
                            analyticsService.trackPlanSaved(
                                planName: trimmedName,
                                data: RaceNutritionResultAnalyticsData(
                                    from: fuelingResult,
                                    calculationId: coordinator.viewModel.calculationId,
                                    wasEdited: wasEdited
                                )
                            )
                            lastSavedFuelingResult = fuelingResult
                            planName = ""
                            showPlanNameDialog = false
                            coordinator.resetAndPopToRoot()
                        } else {
                            errorAlertMessage = viewModel.errorMessage ?? Localizables.Errors.generic
                            viewModel.errorMessage = nil
                            showPlanNameDialog = false
                        }
                    }
                }
                .accessibilityHint(Localizables.AccessibilityHints.tapTo(Localizables.RaceNutritionResults.savePlanButtonHint))
                .disabled(!isPlanNameValid || isSavingPlan)
            } else {
                Button(Localizables.Common.ok, role: .cancel) {
                    errorAlertMessage = nil
                }
            }
        } message: {
            if let errorAlertMessage {
                Text(errorAlertMessage)
            }
        }
        .navigationTitle(screenTitle)
        .onAppear {
            analyticsService.trackScreenView()
            analyticsService.trackFuelingResultGenerated(
                data: RaceNutritionResultAnalyticsData(
                    from: fuelingResult,
                    calculationId: coordinator.viewModel.calculationId
                )
            )
        }
    }
}

// MARK: - Private methods

private extension RaceNutritionResultView {
    var isAlertPresented: Binding<Bool> {
        Binding(
            get: { showPlanNameDialog || errorAlertMessage != nil },
            set: { isPresented in
                if !isPresented {
                    showPlanNameDialog = false
                    errorAlertMessage = nil
                }
            }
        )
    }

    var alertTitle: String {
        errorAlertMessage == nil
            ? Localizables.RaceNutritionResults.savePlanButtonLabel
            : Localizables.Common.error
    }

    var isPlanNameValid: Bool {
        !planName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

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
            VStack(spacing: 12) {
                Text(Localizables.RaceNutritionResults.fuelingPlanTitle)
                    .font(.Custom.Medium.font5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(Localizables.RaceNutritionResults.fuelingPlanTimeColumnTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(Localizables.RaceNutritionResults.fuelingPlanItemColumnTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.Custom.Medium.font2)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                    ForEach(sortedTimeLine, id: \.self) { event in
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                HStack(spacing: 4) {
                                    if event.carbItem.type == .drink {
                                        Image(systemName: "drop.fill")
                                            .font(.Custom.Regular.font1)
                                            .foregroundStyle(.blue)
                                    }

                                    Group {
                                        switch event.consumption {
                                        case let .instant(time):
                                            Text(time.formattedAsHourMinSec)

                                        case let .interval(startTime, endTime):
                                            Text("\(startTime.formattedAsHourMinSec) - \(endTime.formattedAsHourMinSec)")
                                        }
                                    }
                                    .font(.Custom.Medium.font3)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Text(event.carbItem.name)
                                    .font(.Custom.Regular.font3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 6)

                            Divider()
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    var selectedItems: some View {
        if shouldShowSelectedItems {
            GroupBox {
                VStack(alignment: .leading, spacing: 0) {
                    selectedItemsHeader
                        .padding(.bottom, 8)

                    ForEach(fuelingResult.selectedItems) { selection in
                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                Image(systemName: selection.item.type.systemIconName)
                                    .font(.Custom.Regular.font2)
                                    .foregroundStyle(selection.item.type.tintColor)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selection.item.name)
                                        .font(.Custom.Medium.font3)
                                    Text("\(selection.item.type.localized) · \(Int(selection.item.gramsOfCarbs)) \(Localizables.Units.gSymbol)")
                                        .font(.Custom.Regular.font2)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text("\(Int(selection.quantity))×")
                                    .font(.Custom.Medium.font3)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)

                            if selection.id != fuelingResult.selectedItems.last?.id {
                                Divider()
                            }
                        }
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
            analyticsService.trackToggleSelectedItems(expanded: shouldShowSelectedItems)
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
                analyticsService.trackSavePlanClick()
                errorAlertMessage = nil
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

// MARK: - CarbType UI Helpers

private extension CarbType {
    var systemIconName: String {
        switch self {
        case .gel: "flame.fill"
        case .drink: "drop.fill"
        case .solid: "fork.knife"
        case .other: "circle.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .gel: .orange
        case .drink: .blue
        case .solid: .green
        case .other: .gray
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
            ),
            replaceFuelingPlanUseCase: ReplaceFuelingPlanUseCaseDefault(
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
