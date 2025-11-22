//
// TriGuide 2025
//

import Foundation
import CarbItemsSPM
import TriGuideDomain

public protocol RaceNutritionViewFactory {
    @MainActor func buildRaceNutritionView(
        viewModel: RaceNutritionViewModel,
        coordinator: RaceNutritionCoordinator
    ) -> RaceNutritionView

    @MainActor func buildRaceNutritionViewModel() -> RaceNutritionViewModel
    @MainActor func buildCarbItemsCoordinator(
        totalCarbGrams: Double,
        onCompleteSelection: (([CarbItemSelection]) -> Void)?
    ) throws -> CarbItemsCoordinator
}
