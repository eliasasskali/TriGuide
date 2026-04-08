//
// TriGuide 2025
//

import DesignSystem
import Localization
import RaceCalculatorSPM
import SwiftUI
import TriGuideDomain

struct RaceNutritionCalculatorView: View {
    // MARK: - Nested Types

    private enum FocusedField: Hashable {
        case gramsPerHour
        case weight
    }

    private enum ScrollTarget: Hashable {
        case advancedOptions
        case advancedOptionsExpandedEnd
    }

    private enum CarbInputMode: String, CaseIterable {
        case manual
        case estimate

        var title: String {
            switch self {
            case .manual: Localizables.RaceNutritionCalculator.gramsPerHour
            case .estimate: Localizables.RaceNutritionCalculator.estimateFromWeight
            }
        }
    }

    private enum Constants {
        static let maxWeight = 600.0
    }

    // MARK: - Dependencies

    @StateObject var viewModel: RaceNutritionViewModel
    let coordinator: RaceNutritionCoordinator
    let analyticsService: RaceNutritionCalculatorAnalyticsService

    // MARK: - Pace calculator view models

    @StateObject private var runPaceViewModel = PaceCalculatorViewModel(
        paceCalculator: RunningPaceCalculator(),
        paceUnit: .minPerKm
    )
    @StateObject private var bikePaceViewModel = PaceCalculatorViewModel(
        paceCalculator: CyclingPaceCalculator(),
        paceUnit: .kmPerHour
    )
    @StateObject private var swimPaceViewModel = PaceCalculatorViewModel(
        paceCalculator: SwimmingPaceCalculator(),
        paceUnit: .minPer100m
    )

    // MARK: - Properties

    @State private var showPaceCalculatorSheet = false
    @State private var shouldShowAdvancedOptions = false
    @State private var carbInputMode: CarbInputMode = .manual
    @State private var isResettingMode = false
    @FocusState private var focusedField: FocusedField?

    // MARK: - Computed Properties

    var analyticsData: RaceNutritionCalculatorAnalyticsData? {
        guard let duration = viewModel.duration,
              let sport = viewModel.sport?.rawValue,
              let carbsPerHour = viewModel.gramsPerHour,
              let estimatedTotalGrams = viewModel.estimatedTotalGrams
        else { return nil }
        return RaceNutritionCalculatorAnalyticsData(
            calculationId: viewModel.calculationId,
            durationSeconds: duration,
            sport: sport,
            carbInputMode: carbInputMode.rawValue,
            carbsPerHour: carbsPerHour,
            estimatedGramsHourWeight: viewModel.weight,
            estimatedGramsHourIntensity: viewModel.intensity?.rawValue,
            consumedCaffeineBeforeStart: viewModel.hasConsumedCaffeineBefore,
            fastedState: viewModel.fasted,
            fuelingProfile: viewModel.fuelingProfile.rawValue,
            startCarbIntakeAtSeconds: viewModel.startEatingAt,
            ambientTemperature: viewModel.ambientTempC,
            estimatedTotalGrams: estimatedTotalGrams
        )
    }

    // MARK: - Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomActionBar
            }
            .loadingOverlay(isLoading: $viewModel.isLoading)
            .onReceive(viewModel.$didFinishCalculation) { didFinish in
                if didFinish, let totalCarbGrams = viewModel.estimatedTotalGrams {
                    if let analyticsData {
                        analyticsService.trackCalculateFinished(analyticsData: analyticsData)
                    }
                    coordinator.presentCarbItems(totalCarbGrams: totalCarbGrams)
                    viewModel.didFinishCalculation = false
                }
            }
            .onChange(of: shouldShowAdvancedOptions) { _, isExpanded in
                guard isExpanded else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(ScrollTarget.advancedOptionsExpandedEnd, anchor: .bottom)
                    }
                }
            }
            .onChange(of: coordinator.showSavedPlanToast) { _, showToast in
                if showToast {
                    shouldShowAdvancedOptions = false
                    isResettingMode = true
                    carbInputMode = .manual
                }
            }
            .navigationTitle(Localizables.RaceNutritionCalculator.title)
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .hideKeyboardOnTap()
            .sheet(isPresented: $showPaceCalculatorSheet) {
                paceCalculatorSheet
            }
            .onAppear {
                analyticsService.trackScreenView()
            }
        }
        .floatingActionButton(Localizables.Common.reset, systemImage: "arrow.counterclockwise", bottomPadding: 100) {
            analyticsService.trackResetClick()
            coordinator.resetCalculator()
            shouldShowAdvancedOptions = false
            isResettingMode = true
            carbInputMode = .manual
        }
    }
}

// MARK: - Private methods

private extension RaceNutritionCalculatorView {
    var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            title
                .padding(.horizontal)
            sportAndDuration
            carbInputSection
            advancedOptionsSection
                .id(ScrollTarget.advancedOptions)
            Color.clear
                .frame(height: 1)
                .id(ScrollTarget.advancedOptionsExpandedEnd)
        }
    }

    var bottomActionBar: some View {
        VStack(spacing: 0) {
            totalsSummary
                .padding(.horizontal)

            ActionButton(
                Localizables.RaceNutritionCalculator.calculateButtonTitle,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.isButtonDisabled,
                accessibilityHint: Localizables.AccessibilityHints.tapTo(
                    Localizables.RaceNutritionCalculator.calculateButtonTitle
                ),
                action: {
                    analyticsService.trackCalculateClick()
                    viewModel.calculateTotalGrams()
                }
            )
            .padding(.horizontal)
            .padding(.vertical, viewModel.estimatedTotalGrams != nil ? 8 : 16)
        }
        .frame(maxWidth: .infinity)
        .background(.bar)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    var title: some View {
        Text(Localizables.RaceNutritionCalculator.subTitle)
            .font(.Custom.Regular.font3)
            .foregroundColor(.gray)
    }

    var sportAndDuration: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text(Localizables.RaceNutritionCalculator.firstSectionTitle)
                    .font(.Custom.Medium.font4)

                HStack(spacing: 8) {
                    DurationPickerView(
                        title: Localizables.RaceNutritionCalculator.duration,
                        duration: $viewModel.duration
                    )

                    Menu {
                        ForEach(SupportedSport.nutritionSupportedSports, id: \.self) { sport in
                            Button {
                                viewModel.sport = sport
                            } label: {
                                Text(sport.localized)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Localizables.Common.sport)
                                .font(.Custom.Medium.font1)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                ZStack(alignment: .leading) {
                                    ForEach(SupportedSport.nutritionSupportedSports, id: \.self) { sport in
                                        Text(sport.localized).hidden()
                                    }
                                    Text(viewModel.sport?.localized ?? Localizables.RaceNutritionCalculator.selectSport)
                                }
                                Image(systemName: "chevron.up.chevron.down")
                                    .imageScale(.small)
                            }
                            .font(.Custom.Regular.font2)
                            .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.lightGray).opacity(0.2))
                        )
                    }
                }

                Button {
                    guard viewModel.sport != nil else { return }
                    analyticsService.trackUseTimeCalculatorClick()
                    showPaceCalculatorSheet = true
                } label: {
                    Label(Localizables.RaceNutritionCalculator.useTimeCalculator, systemImage: "clock")
                        .font(.Custom.Regular.font3)
                }
                .buttonStyle(.borderless)
                .padding(.top, 4)
                .disabled(viewModel.sport == nil)
            }
        }
    }

    var carbInputSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(Localizables.RaceNutritionCalculator.secondSectionTitle)
                        .font(.Custom.Medium.font4)

                    Spacer()

                    InfoLabel(
                        title: Localizables.RaceNutritionCalculator.carbsEstimationInformationTitle,
                        content: {
                            Text(Localizables.RaceNutritionCalculator.carbsEstimationInformationDescription)
                        }
                    )
                }

                Picker(Localizables.RaceNutritionCalculator.secondSectionTitle, selection: $carbInputMode) {
                    ForEach(CarbInputMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: carbInputMode) { _, newValue in
                    guard !isResettingMode else {
                        isResettingMode = false
                        return
                    }
                    analyticsService.trackCarbInputModeChange(mode: newValue.rawValue)
                }

                switch carbInputMode {
                case .manual:
                    TextField(
                        Localizables.RaceNutritionCalculator.gramsPerHour,
                        value: $viewModel.gramsPerHour,
                        format: .number
                    )
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .gramsPerHour)
                    .cardBackground(innerHorizontalPadding: 12, innerVerticalPadding: 12)

                case .estimate:
                    HStack(spacing: 8) {
                        TextField(Localizables.RaceNutritionCalculator.weightKg, value: $viewModel.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weight)
                            .cardBackground(innerHorizontalPadding: 12, innerVerticalPadding: 12)
                            .onChange(of: viewModel.weight) { _, newValue in
                                if let val = newValue, val > Constants.maxWeight {
                                    viewModel.weight = Constants.maxWeight
                                }
                            }

                        Menu {
                            ForEach(Intensity.allCases, id: \.self) { intensity in
                                Button {
                                    viewModel.intensity = intensity
                                } label: {
                                    Text(intensity.localized)
                                }
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Localizables.Common.intensity)
                                    .font(.Custom.Medium.font1)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 4) {
                                    ZStack(alignment: .leading) {
                                        // Hidden sizing text for the widest label to prevent layout jumps
                                        ForEach(Intensity.allCases, id: \.self) { intensity in
                                            Text(intensity.localized).hidden()
                                        }
                                        Text(viewModel.intensity?.localized ?? Localizables.Common.intensity)
                                    }
                                    Image(systemName: "chevron.up.chevron.down")
                                        .imageScale(.small)
                                }
                                .font(.Custom.Regular.font2)
                                .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.lightGray).opacity(0.2))
                            )
                        }
                    }

                    if let gramsPerHour = viewModel.gramsPerHour, viewModel.weight != nil, viewModel.intensity != nil, viewModel.sport != nil {
                        if gramsPerHour > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.Custom.Medium.font2)
                                Text(String(format: Localizables.RaceNutritionCalculator.estimatedCarbsPerHour, "\(Int(gramsPerHour))"))
                                    .font(.Custom.Medium.font3)
                            }
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Localizables.RaceNutritionCalculator.noCarbsNeededTitle)
                                    .font(.Custom.Bold.font3)
                                Text(Localizables.RaceNutritionCalculator.noCarbsNeededDescription)
                                    .font(.Custom.Regular.font2)
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if viewModel.sport == nil && viewModel.intensity != nil && viewModel.weight != nil {
                        Text(Localizables.RaceNutritionCalculator.gramsPerHourEstimateSelectSportError)
                            .font(.Custom.Regular.font2)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var totalsSummary: some View {
        if let totalGrams = viewModel.estimatedTotalGrams {
            GroupBox {
                HStack(spacing: 4) {
                    Text(Localizables.RaceNutritionCalculator.estimatedTotalCarbs)
                        .font(.Custom.Medium.font3)
                    Text("\(Int(totalGrams)) \(Localizables.Units.gSymbol)")
                        .font(.Custom.Bold.font3)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    var paceCalculatorSheet: some View {
        NavigationStack {
            Group {
                switch viewModel.sport {
                case .run:
                    PaceTimeCalculatorView<RunningDistance>(
                        sport: .run,
                        viewModel: runPaceViewModel,
                        duration: $viewModel.duration
                    )

                case .bike:
                    PaceTimeCalculatorView<CyclingDistance>(
                        sport: .bike,
                        viewModel: bikePaceViewModel,
                        duration: $viewModel.duration
                    )

                case .swim:
                    PaceTimeCalculatorView<SwimmingDistance>(
                        sport: .swim,
                        viewModel: swimPaceViewModel,
                        duration: $viewModel.duration
                    )

                default:
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle(Localizables.RaceNutritionCalculator.useTimeCalculator)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Localizables.Common.done) {
                        showPaceCalculatorSheet = false
                    }
                }
            }
        }
        .presentationDetents([.height(280)])
    }

    var advancedOptionsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(Localizables.RaceNutritionCalculator.advancedOptions)
                        .font(.Custom.Medium.font4)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(shouldShowAdvancedOptions ? 180 : 0))
                        .animation(.easeInOut, value: shouldShowAdvancedOptions)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        shouldShowAdvancedOptions.toggle()
                    }
                    analyticsService.trackAdvancedOptionsClick()
                }

                if shouldShowAdvancedOptions {
                    toggleField(
                        isOn: $viewModel.hasConsumedCaffeineBefore,
                        label: Localizables.RaceNutritionCalculator.consumedCaffeineBefore,
                        infoLabelDescription: Localizables.RaceNutritionCalculator.consumedCaffeineBeforeInformationDescription
                    )

                    toggleField(
                        isOn: $viewModel.fasted,
                        label: Localizables.RaceNutritionCalculator.fastedState,
                        infoLabelDescription: Localizables.RaceNutritionCalculator.fastedStateInformationDescription
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 8) {
                            InfoLabel {
                                Text(Localizables.FuelingProfile.informationDescription)
                            }
                            Text(Localizables.FuelingProfile.title)
                        }

                        Picker(Localizables.FuelingProfile.title, selection: $viewModel.fuelingProfile) {
                            ForEach(FuelingProfile.allCases, id: \.self) { profile in
                                Text(profile.localized).tag(profile)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    sliderField(
                        label: Localizables.RaceNutritionCalculator.startEatingAt,
                        infoLabelDescription: Localizables.RaceNutritionCalculator.startEatingAtInformationDescription,
                        value: viewModel.startEatingAt.formattedAsHourMin,
                        sliderValue: $viewModel.startEatingAt,
                        sliderLabel: Localizables.RaceNutritionCalculator.startEatingAt,
                        range: 0 ... max(viewModel.duration ?? 900, 900),
                        roundingStep: 60
                    )

                    sliderField(
                        label: Localizables.RaceNutritionCalculator.ambientTemperatureC,
                        infoLabelDescription: Localizables.RaceNutritionCalculator.ambientTemperatureInformationDescription,
                        value: "\(Int(viewModel.ambientTempC))\(Localizables.Units.celsiusSymbol)",
                        sliderValue: $viewModel.ambientTempC,
                        sliderLabel: Localizables.RaceNutritionCalculator.ambientTemperature,
                        range: -10 ... 50,
                        roundingStep: 1
                    )
                }
            }
        }
    }

    func toggleField(
        isOn: Binding<Bool>,
        label: String,
        infoLabelDescription: @autoclosure @escaping () -> String
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(alignment: .center, spacing: 8) {
                InfoLabel {
                    Text(infoLabelDescription())
                }
                Text(label)
            }
        }
    }

    @ViewBuilder
    func sliderField(
        label: String,
        infoLabelDescription: @autoclosure @escaping () -> String,
        value: String,
        sliderValue: Binding<Double>,
        sliderLabel: String,
        range: ClosedRange<Double>,
        roundingStep: Double? = nil
    ) -> some View {
        let binding: Binding<Double> = if let roundingStep {
            Binding(
                get: { sliderValue.wrappedValue },
                set: { sliderValue.wrappedValue = (($0 / roundingStep).rounded() * roundingStep) }
            )
        } else {
            sliderValue
        }
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack {
                    InfoLabel {
                        Text(infoLabelDescription())
                    }
                    Text(label)
                    Spacer()
                    Text(value)
                        .monospacedDigit()
                }
            }
            Slider(
                value: binding,
                in: range
            ) {
                Text(sliderLabel)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Preview

#Preview {
    RaceNutritionCalculatorView(
        viewModel: RaceNutritionViewModel(
            calculateFuelingResultUseCase: CalculateFuelingResultUseCaseDefault(
                dataSource: LocalFuelingCalculator()
            )
        ),
        coordinator: RaceNutritionCoordinator(
            factory: RaceNutritionViewFactoryDefault(
                dependencies: .init()
            )
        ),
        analyticsService: RaceNutritionCalculatorAnalyticsServiceNoOp()
    )
}
