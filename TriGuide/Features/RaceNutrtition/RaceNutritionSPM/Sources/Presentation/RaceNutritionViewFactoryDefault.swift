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
        let replaceFuelingPlanUseCase: ReplaceFuelingPlanUseCase
        let raceNutritionCalculatorAnalyticsService: RaceNutritionCalculatorAnalyticsService
        let raceNutritionResultAnalyticsService: RaceNutritionResultAnalyticsService
        let fuelingPlanEditAnalyticsService: FuelingPlanEditAnalyticsService
        let carbItemsAnalyticsService: CarbItemsAnalyticsService

        public init(
            fuelingCalculatorDataSource: FuelingCalculatorDataSource? = nil,
            calculateFuelingResultUseCase: CalculateFuelingResultUseCase? = nil,
            nutritionPlansRepository: NutritionPlansRepository? = nil,
            saveFuelingPlanUseCase: SaveFuelingPlanUseCase? = nil,
            fetchStoredFuelingResultsUseCase: FetchStoredFuelingResultsUseCase? = nil,
            deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCase? = nil,
            raceNutritionCalculatorAnalyticsService: RaceNutritionCalculatorAnalyticsService? = nil,
            raceNutritionResultAnalyticsService: RaceNutritionResultAnalyticsService? = nil,
            fuelingPlanEditAnalyticsService: FuelingPlanEditAnalyticsService? = nil,
            carbItemsAnalyticsService: CarbItemsAnalyticsService? = nil
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
            replaceFuelingPlanUseCase = ReplaceFuelingPlanUseCaseDefault(repository: repository)
            self.raceNutritionCalculatorAnalyticsService = raceNutritionCalculatorAnalyticsService ?? RaceNutritionCalculatorAnalyticsServiceNoOp()
            self.raceNutritionResultAnalyticsService = raceNutritionResultAnalyticsService ?? RaceNutritionResultAnalyticsServiceNoOp()
            self.fuelingPlanEditAnalyticsService = fuelingPlanEditAnalyticsService ?? FuelingPlanEditAnalyticsServiceNoOp()
            self.carbItemsAnalyticsService = carbItemsAnalyticsService ?? CarbItemsAnalyticsServiceNoOp()
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
    public var fuelingPlanEditAnalyticsService: FuelingPlanEditAnalyticsService {
        dependencies.fuelingPlanEditAnalyticsService
    }

    @MainActor public func buildRaceNutritionView(
        viewModel: RaceNutritionViewModel,
        coordinator: RaceNutritionCoordinator
    ) -> RaceNutritionView {
        RaceNutritionView(
            viewModel: viewModel,
            coordinator: coordinator,
            factory: self,
            raceNutritionCalculatorAnalyticsService: dependencies.raceNutritionCalculatorAnalyticsService
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
        let carbItemsFactory = try CarbItemsViewFactoryDefault(
            dependencies: .init(
                carbItemsAnalyticsService: dependencies.carbItemsAnalyticsService,
                totalCarbGrams: totalCarbGrams
            )
        )
        return CarbItemsCoordinator(
            factory: carbItemsFactory,
            analyticsService: dependencies.carbItemsAnalyticsService,
            onCompleteSelection: onCompleteSelection
        )
    }

    @MainActor public func buildRaceNutritionResultView(
        coordinator: RaceNutritionCoordinator,
        viewModel: RaceNutritionResultViewModel,
        showSaveButton: Bool,
        fuelingResult: Binding<FuelingResult>
    ) -> RaceNutritionResultView {
        return RaceNutritionResultView(
            coordinator: coordinator,
            viewModel: viewModel,
            analyticsService: dependencies.raceNutritionResultAnalyticsService,
            showSaveButton: showSaveButton,
            fuelingResult: fuelingResult
        )
    }

    @MainActor public func buildRaceNutritionResultViewModel() -> RaceNutritionResultViewModel {
        RaceNutritionResultViewModel(
            saveFuelingPlanUseCase: dependencies.saveFuelingPlanUseCase,
            deleteStoredFuelingResultUseCase: dependencies.deleteStoredFuelingResultUseCase,
            replaceFuelingPlanUseCase: dependencies.replaceFuelingPlanUseCase
        )
    }

    @MainActor public func buildStoredNutritionPlansListViewModel() -> StoredNutritionPlansListViewModel {
        StoredNutritionPlansListViewModel(
            fetchStoredFuelingResultsUseCase: dependencies.fetchStoredFuelingResultsUseCase,
            deleteStoredFuelingResultUseCase: dependencies.deleteStoredFuelingResultUseCase
        )
    }

    @MainActor public func buildStoredNutritionPlansListView(
        coordinator: RaceNutritionCoordinator?
    ) -> StoredNutritionPlansListView {
        StoredNutritionPlansListView(
            viewModel: buildStoredNutritionPlansListViewModel(),
            coordinator: coordinator
        )
    }
}
