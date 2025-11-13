//
// TriGuide 2025
//

import SwiftUI
import TriGuideDomain
import FormKit
import RaceCalculatorSPM
import DesignSystem
import Localization

struct RaceNutritionCalculatorView: View {
    @StateObject var viewModel: RaceNutritionViewModel
    let coordinator: RaceNutritionCoordinator

    @State private var shouldShowPaceCalculator = false
    @State private var shouldShowAdvancedOptions = false
    @State private var shouldShowSelectSportErrorOnPaceCalculator = false

    var shouldShowSelectSportErrorOnGramsPerHour: Bool {
        viewModel.sport == nil &&
        viewModel.intensity != nil &&
        viewModel.weight != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Title & Description
                    Text(Localizables.RaceNutritionCalculator.subTitle)
                        .font(.Custom.Regular.font3)
                        .foregroundColor(.gray)

                    // MARK: - Sport & Duration
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

                    // MARK: - Carbs Input / Estimate
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(Localizables.RaceNutritionCalculator.secondSectionTitle)
                                .font(.Custom.Medium.font4)

                            Text(Localizables.RaceNutritionCalculator.secondSectionDescription)
                                .font(.Custom.Regular.font3)
                                .foregroundColor(.gray)

                            TextField(
                                Localizables.RaceNutritionCalculator.gramsPerHour,
                                value: $viewModel.gramsPerHour,
                                format: .number
                            )
                            .keyboardType(.decimalPad)
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

                    // MARK: - Advanced Options
                    advancedOptionsSection
                }
            }
            // MARK: - Total Summary
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

            // MARK: - Calculate Button
            ActionButton(
                Localizables.RaceNutritionCalculator.calculateButtonTitle,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.isButtonDisabled,
                action: {
                    viewModel.calculateTotalGrams()
                }
            )
            .padding(.bottom, 8)
        }
        .onReceive(viewModel.$didFinishCalculation) { didFinish in
            if didFinish, let totalCarbGrams = viewModel.estimatedTotalGrams {
                coordinator.presentCarbItems(totalCarbGrams: totalCarbGrams)
                viewModel.didFinishCalculation = false
            }
        }
        .navigationTitle(Localizables.RaceNutritionCalculator.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
    }
}

// MARK: - Subviews
private extension RaceNutritionCalculatorView {

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
                    shouldShowAdvancedOptions.toggle()
                }

                if shouldShowAdvancedOptions {
                    Toggle(isOn: $viewModel.fasted) {
                        Label(Localizables.RaceNutritionCalculator.fastedState, systemImage: "info.circle")
                            .onTapGesture {
                                // TODO: Show info about fasted state
                            }
                    }

                    Toggle(isOn: $viewModel.gutTrained) {
                        Label(Localizables.RaceNutritionCalculator.gutTrained, systemImage: "info.circle")
                            .onTapGesture {
                                // TODO: Show info about gut training
                            }
                    }

                    Toggle(isOn: $viewModel.capped) {
                        Label(Localizables.RaceNutritionCalculator.applyAmateurLimits, systemImage: "info.circle")
                            .onTapGesture {
                                // TODO: Show info about amateur caps
                            }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(Localizables.RaceNutritionCalculator.ambientTemperatureC, systemImage: "info.circle")
                                .onTapGesture {
                                    // TODO: Show info about ambient temperature
                                }
                            Spacer()
                            Text("\(Int(viewModel.ambientTempC))\(Localizables.Units.celsiusSymbol)")
                                .monospacedDigit()
                        }
                        Slider(
                            value: $viewModel.ambientTempC,
                            in: -10...50,
                            step: 1
                        ) { Text(Localizables.RaceNutritionCalculator.ambientTemperature) }
                    }
                    .padding(.top, 4)
                }
            }
        }
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
        viewModel: RaceNutritionViewModel(),
        coordinator: RaceNutritionCoordinator(
            factory: RaceNutritionViewFactoryDefault(
                dependencies: .init()
            )
        )
    )
}
