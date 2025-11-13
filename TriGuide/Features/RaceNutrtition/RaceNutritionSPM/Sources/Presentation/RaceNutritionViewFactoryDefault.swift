//
// TriGuide 2025
//

import CarbItemsSPM
import FormKit

public final class RaceNutritionViewFactoryDefault {
    public struct Dependencies {

        public init() {

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
        RaceNutritionViewModel()
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
