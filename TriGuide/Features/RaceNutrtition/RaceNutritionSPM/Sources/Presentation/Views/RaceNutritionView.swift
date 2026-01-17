//
// TriGuide 2025
//

import SwiftUI

public struct RaceNutritionView: View {
    @ObservedObject private var viewModel: RaceNutritionViewModel
    @ObservedObject private var coordinator: RaceNutritionCoordinator

    public init(
        viewModel: RaceNutritionViewModel,
        coordinator: RaceNutritionCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        NavigationStack(path: coordinator.pathBinding) {
            VStack {
                RaceNutritionCalculatorView(
                    viewModel: viewModel,
                    coordinator: coordinator
                )
            }
            .sheet(item: coordinator.sheetBinding) { sheet in
                switch sheet {
                case .carbItems(let totalGrams):
                    coordinator.buildCarbItemsView(totalCarbGrams: totalGrams)
                }
            }
            .navigationDestination(for: RaceNutritionCoordinator.Path.self) { path in
                switch path {
                case .raceNutritionResult:
                    if let binding = Binding(
                        get: { viewModel.fuelingResult },
                        set: { viewModel.fuelingResult = $0 }
                    ).unwrap() {
                        RaceNutritionResultView(
                            coordinator: coordinator,
                            fuelingResult: binding
                        )
                    } else {
                        EmptyView()
                    }

                case .fuelingPlanFullView:
                    if let binding = Binding(
                        get: { viewModel.fuelingResult },
                        set: { viewModel.fuelingResult = $0 }
                    ).unwrap() {
                        FuelingPlanEditView(result: binding)
                    }
                }
            }
        }
    }
}
