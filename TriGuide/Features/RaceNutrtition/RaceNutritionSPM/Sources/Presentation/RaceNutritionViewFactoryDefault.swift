//
// TriGuide 2025
//

import CarbItemsSPM
import FormKit
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

    private let dependencies: Dependencies

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
        let carbItemsFactory = CarbItemsViewFactoryDefault(dependencies: try .init(totalCarbGrams: totalCarbGrams))
        return CarbItemsCoordinator(
            factory: carbItemsFactory,
            onCompleteSelection: onCompleteSelection
        )
    }
}
