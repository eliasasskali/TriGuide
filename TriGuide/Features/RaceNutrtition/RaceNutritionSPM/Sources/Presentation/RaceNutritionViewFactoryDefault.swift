//
// TriGuide 2025
//

import CarbItemsSPM
import SwiftUI
import TriGuideDomain

public final class RaceNutritionViewFactoryDefault {
    public struct Dependencies {
        let fuelingCalculatorDataSource: FuelingCalculatorDataSource
        let calculateFuelingResultUseCase: CalculateFuelingResultUseCase
        let saveFuelingPlanUseCase: SaveFuelingPlanUseCase
        let fetchStoredFuelingResultsUseCase: FetchStoredFuelingResultsUseCase
        let deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCase

        public init(
            fuelingCalculatorDataSource: FuelingCalculatorDataSource? = nil,
            calculateFuelingResultUseCase: CalculateFuelingResultUseCase? = nil,
            nutritionPlansRepository: NutritionPlansRepository? = nil,
            saveFuelingPlanUseCase: SaveFuelingPlanUseCase? = nil,
            fetchStoredFuelingResultsUseCase: FetchStoredFuelingResultsUseCase? = nil,
            deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCase? = nil
        ) {
            self.fuelingCalculatorDataSource = fuelingCalculatorDataSource ?? LocalFuelingCalculator()
            self.calculateFuelingResultUseCase = calculateFuelingResultUseCase ?? CalculateFuelingResultUseCaseDefault(
                dataSource: self.fuelingCalculatorDataSource
            )

            let repository: NutritionPlansRepository
            if let nutritionPlansRepository {
                repository = nutritionPlansRepository
            } else {
                do {
                    let dataSource = try StoredNutritionPlansDataSourceDefault()
                    repository = NutritionPlansRepositoryDefault(
                        nutritionPlansDataSource: dataSource
                    )
                } catch {
                    fatalError("Failed to create StoredNutritionPlansDataSourceDefault: \(error)")
                }
            }

            self.saveFuelingPlanUseCase = saveFuelingPlanUseCase ?? SaveFuelingPlanUseCaseDefault(repository: repository)
            self.fetchStoredFuelingResultsUseCase = fetchStoredFuelingResultsUseCase
                ?? FetchStoredFuelingResultsUseCaseDefault(repository: repository)
            self.deleteStoredFuelingResultUseCase = deleteStoredFuelingResultUseCase
                ?? DeleteStoredFuelingResultUseCaseDefault(repository: repository)
        }
    }

    // MARK: - Dependencies

    private let dependencies: Dependencies

    // MARK: - Initializer

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - RaceNutritionViewFactory

extension RaceNutritionViewFactoryDefault: RaceNutritionViewFactory {
    @MainActor public func buildRaceNutritionView(
        viewModel: RaceNutritionViewModel,
        coordinator: RaceNutritionCoordinator
    ) -> RaceNutritionView {
        RaceNutritionView(
            viewModel: viewModel,
            coordinator: coordinator,
            factory: self
        )
    }

    @MainActor public func buildRaceNutritionViewModel() -> RaceNutritionViewModel {
        RaceNutritionViewModel(
            calculateFuelingResultUseCase: dependencies.calculateFuelingResultUseCase
        )
    }

    @MainActor public func buildCarbItemsCoordinator(
        totalCarbGrams: Double,
        onCompleteSelection: (([CarbItemSelection]) -> Void)?
    ) throws -> CarbItemsCoordinator {
        let carbItemsFactory = try CarbItemsViewFactoryDefault(dependencies: .init(totalCarbGrams: totalCarbGrams))
        return CarbItemsCoordinator(
            factory: carbItemsFactory,
            onCompleteSelection: onCompleteSelection
        )
    }

    @MainActor public func buildRaceNutritionResultView(
        coordinator: RaceNutritionCoordinator,
        fuelingResult: Binding<FuelingResult>
    ) -> RaceNutritionResultView {
        let viewModel = RaceNutritionResultViewModel(saveFuelingPlanUseCase: dependencies.saveFuelingPlanUseCase)
        return RaceNutritionResultView(
            coordinator: coordinator,
            viewModel: viewModel,
            fuelingResult: fuelingResult
        )
    }

    @MainActor public func buildStoredNutritionPlansListViewModel() -> StoredNutritionPlansListViewModel {
        StoredNutritionPlansListViewModel(
            fetchStoredFuelingResultsUseCase: dependencies.fetchStoredFuelingResultsUseCase,
            deleteStoredFuelingResultUseCase: dependencies.deleteStoredFuelingResultUseCase
        )
    }

    @MainActor public func buildStoredNutritionPlansListView() -> StoredNutritionPlansListView {
        StoredNutritionPlansListView(viewModel: buildStoredNutritionPlansListViewModel())
    }
}
