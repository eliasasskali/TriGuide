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

    // MARK: - Dependencies

    @StateObject var viewModel: RaceNutritionViewModel
    let coordinator: RaceNutritionCoordinator

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
    @FocusState private var focusedField: FocusedField?

    // MARK: - Body

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
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
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomActionBar
            }
            .loadingOverlay(isLoading: $viewModel.isLoading)
            .onReceive(viewModel.$didFinishCalculation) { didFinish in
                if didFinish, let totalCarbGrams = viewModel.estimatedTotalGrams {
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
            .navigationTitle(Localizables.RaceNutritionCalculator.title)
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .hideKeyboardOnTap()
            .sheet(isPresented: $showPaceCalculatorSheet) {
                paceCalculatorSheet
            }
        }
    }
}

// MARK: - Private methods

private extension RaceNutritionCalculatorView {
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
                                if let val = newValue, val > 999 {
                                    viewModel.weight = 999
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
                        range: -0 ... (viewModel.duration ?? 900),
                        step: 300
                    )

                    sliderField(
                        label: Localizables.RaceNutritionCalculator.ambientTemperatureC,
                        infoLabelDescription: Localizables.RaceNutritionCalculator.ambientTemperatureInformationDescription,
                        value: "\(Int(viewModel.ambientTempC))\(Localizables.Units.celsiusSymbol)",
                        sliderValue: $viewModel.ambientTempC,
                        sliderLabel: Localizables.RaceNutritionCalculator.ambientTemperature,
                        range: -10 ... 50
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

    func sliderField(
        label: String,
        infoLabelDescription: @autoclosure @escaping () -> String,
        value: String,
        sliderValue: Binding<Double>,
        sliderLabel: String,
        range: ClosedRange<Double>,
        step: Double = 1
    ) -> some View {
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
                value: sliderValue,
                in: range,
                step: step
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
        )
    )
}
