//
// TriGuide 2025
//

import CarbItemsSPM
import TriGuideDomain

public final class RaceNutritionViewFactoryDefault {
    public struct Dependencies {
        let fuelingCalculatorDataSource: FuelingCalculatorDataSource
        let calculateFuelingResultUseCase: CalculateFuelingResultUseCase

        public init(
            fuelingCalculatorDataSource: FuelingCalculatorDataSource? = nil,
            calculateFuelingResultUseCase: CalculateFuelingResultUseCase? = nil
        ) {
            self.fuelingCalculatorDataSource = fuelingCalculatorDataSource ?? LocalFuelingCalculator()
            self.calculateFuelingResultUseCase = calculateFuelingResultUseCase ?? CalculateFuelingResultUseCaseDefault(
                dataSource: self.fuelingCalculatorDataSource
            )
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
            coordinator: coordinator
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
}
