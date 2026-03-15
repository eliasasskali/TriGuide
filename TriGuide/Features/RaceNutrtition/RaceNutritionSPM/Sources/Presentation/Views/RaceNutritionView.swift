//
// TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI

public struct RaceNutritionView: View {
    // MARK: - Dependencies

    @ObservedObject private var viewModel: RaceNutritionViewModel
    @ObservedObject private var coordinator: RaceNutritionCoordinator

    private let factory: RaceNutritionViewFactory
    private let raceNutritionCalculatorAnalyticsService: RaceNutritionCalculatorAnalyticsService

    // MARK: - Initializer

    public init(
        viewModel: RaceNutritionViewModel,
        coordinator: RaceNutritionCoordinator,
        factory: RaceNutritionViewFactory,
        raceNutritionCalculatorAnalyticsService: RaceNutritionCalculatorAnalyticsService
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.factory = factory
        self.raceNutritionCalculatorAnalyticsService = raceNutritionCalculatorAnalyticsService
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: coordinator.pathBinding) {
            VStack {
                RaceNutritionCalculatorView(
                    viewModel: viewModel,
                    coordinator: coordinator,
                    analyticsService: raceNutritionCalculatorAnalyticsService
                )
            }
            .toast(
                isPresented: $coordinator.showSavedPlanToast,
                message: Localizables.RaceNutritionResults.saveSuccessToastMessage
            )
            .sheet(item: coordinator.sheetBinding) { sheet in
                switch sheet {
                case let .carbItems(totalGrams):
                    coordinator.buildCarbItemsView(totalCarbGrams: totalGrams)
                }
            }
            .navigationDestination(for: RaceNutritionCoordinator.Path.self) { path in
                switch path {
                case .raceNutritionResult:
                    coordinator.buildRaceNutritionResultDestination()

                case .fuelingPlanFullView:
                    coordinator.buildFuelingPlanEditDestination()
                }
            }
        }
    }
}
