//
// TriGuide 2025
//

import Foundation
import CarbItemsSPM

public protocol RaceNutritionViewFactory {
    @MainActor func buildRaceNutritionView(
        viewModel: RaceNutritionViewModel,
        coordinator: RaceNutritionCoordinator
    ) -> RaceNutritionView

    @MainActor func buildRaceNutritionViewModel() -> RaceNutritionViewModel
    @MainActor func buildCarbItemsCoordinator() throws -> CarbItemsCoordinator
}
