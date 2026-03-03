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

    // MARK: - Dependencies

    @StateObject var viewModel: RaceNutritionViewModel
    let coordinator: RaceNutritionCoordinator

    // MARK: - Properties

    @State private var shouldShowPaceCalculator = false
    @State private var shouldShowAdvancedOptions = false
    @State private var shouldShowSelectSportErrorOnPaceCalculator = false
    @FocusState private var focusedField: FocusedField?

    // MARK: - Computed properties

    var shouldShowSelectSportErrorOnGramsPerHour: Bool {
        viewModel.sport == nil &&
            viewModel.intensity != nil &&
            viewModel.weight != nil
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    title
                        .padding(.horizontal)
                    sportAndDuration
                    carbInputOrEstimate
                    advancedOptionsSection
                }
            }
            .scrollDismissesKeyboard(.interactively)

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
            .padding(.bottom, 8)
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .onReceive(viewModel.$didFinishCalculation) { didFinish in
            if didFinish, let totalCarbGrams = viewModel.estimatedTotalGrams {
                coordinator.presentCarbItems(totalCarbGrams: totalCarbGrams)
                viewModel.didFinishCalculation = false
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Localizables.Common.done) {
                    focusedField = nil
                }
            }
        }
        .navigationTitle(Localizables.RaceNutritionCalculator.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
    }
}

// MARK: - Private methods

private extension RaceNutritionCalculatorView {
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

                    Picker(Localizables.Common.sport, selection: $viewModel.sport) {
                        Text(Localizables.RaceNutritionCalculator.selectSport).tag(nil as SupportedSport?)
                        ForEach(SupportedSport.singleSports, id: \.self) { sport in
                            Text(sport.localized).tag(sport)
                        }
                    }
                    .tint(.blue)
                }

                Button {
                    togglePaceCalculator()
                } label: {
                    Label(Localizables.RaceNutritionCalculator.useTimeCalculator, systemImage: "clock")
                        .font(.Custom.Regular.font3)
                }
                .buttonStyle(.borderless)
                .padding(.top, 4)

                if shouldShowSelectSportErrorOnPaceCalculator {
                    Text(Localizables.RaceNutritionCalculator.paceCalculatorSelectSportError)
                        .font(.Custom.Regular.font2)
                        .foregroundColor(.red)
                }

                if shouldShowPaceCalculator {
                    paceCalculatorSection
                }
            }
        }
    }

    var carbInputOrEstimate: some View {
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
                Text(Localizables.RaceNutritionCalculator.secondSectionDescription)
                    .font(.Custom.Regular.font3)
                    .foregroundColor(.gray)

                TextField(
                    Localizables.RaceNutritionCalculator.gramsPerHour,
                    value: $viewModel.gramsPerHour,
                    format: .number
                )
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .gramsPerHour)
                .cardBackground(innerHorizontalPadding: 12, innerVerticalPadding: 12)

                HStack {
                    Divider().overlay(Color.gray.opacity(0.3))
                    Text(Localizables.Common.or.uppercased())
                        .font(.Custom.Regular.font3)
                        .foregroundColor(.gray)
                    Divider().overlay(Color.gray.opacity(0.3))
                }
                .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 8) {
                    TextField(Localizables.RaceNutritionCalculator.weightKg, value: $viewModel.weight, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                        .cardBackground(innerHorizontalPadding: 12, innerVerticalPadding: 12)

                    Picker(Localizables.Common.intensity, selection: $viewModel.intensity) {
                        Text(Localizables.Common.intensity).tag(nil as Intensity?)
                        ForEach(Intensity.allCases, id: \.self) { intensity in
                            Text(intensity.localized).tag(intensity)
                        }
                    }
                    .tint(.blue)
                }

                if shouldShowSelectSportErrorOnGramsPerHour {
                    Text(Localizables.RaceNutritionCalculator.gramsPerHourEstimateSelectSportError)
                        .font(.Custom.Regular.font2)
                        .foregroundColor(.red)
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
    var paceCalculatorSection: some View {
        switch viewModel.sport {
        case .run:
            PaceTimeCalculatorView<RunningDistance>(
                sport: .run,
                viewModel: PaceCalculatorViewModel(
                    paceCalculator: RunningPaceCalculator(),
                    paceUnit: .minPerKm
                ),
                duration: $viewModel.duration
            )

        case .bike:
            PaceTimeCalculatorView<CyclingDistance>(
                sport: .bike,
                viewModel: PaceCalculatorViewModel(
                    paceCalculator: CyclingPaceCalculator(),
                    paceUnit: .kmPerHour
                ),
                duration: $viewModel.duration
            )

        case .swim:
            PaceTimeCalculatorView<SwimmingDistance>(
                sport: .swim,
                viewModel: PaceCalculatorViewModel(
                    paceCalculator: SwimmingPaceCalculator(),
                    paceUnit: .minPer100m
                ),
                duration: $viewModel.duration
            )

        default:
            EmptyView()
        }
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

                    toggleField(
                        isOn: $viewModel.gutTrained,
                        label: Localizables.RaceNutritionCalculator.gutTrained,
                        infoLabelDescription: Localizables.RaceNutritionCalculator.gutTrainedInformationDescription
                    )

                    toggleField(
                        isOn: $viewModel.capped,
                        label: Localizables.RaceNutritionCalculator.applyAmateurLimits,
                        infoLabelDescription: Localizables.RaceNutritionCalculator.applyAmateurLimitsInformationDescription
                    )

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

    func togglePaceCalculator() {
        guard viewModel.sport != nil else {
            shouldShowSelectSportErrorOnPaceCalculator = true
            return
        }
        shouldShowSelectSportErrorOnPaceCalculator = false
        shouldShowPaceCalculator.toggle()
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
