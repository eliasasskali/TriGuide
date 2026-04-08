//
// TriGuide 2025
//

import CarbItemsSPM
import Foundation
import SwiftUI
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

    @MainActor func buildRaceNutritionResultView(
        coordinator: RaceNutritionCoordinator,
        viewModel: RaceNutritionResultViewModel,
        showSaveButton: Bool,
        fuelingResult: Binding<FuelingResult>
    ) -> RaceNutritionResultView

    var fuelingPlanEditAnalyticsService: FuelingPlanEditAnalyticsService { get }

    @MainActor func buildRaceNutritionResultViewModel() -> RaceNutritionResultViewModel

    @MainActor func buildStoredNutritionPlansListViewModel() -> StoredNutritionPlansListViewModel

    @MainActor func buildStoredNutritionPlansListView(
        coordinator: RaceNutritionCoordinator?
    ) -> StoredNutritionPlansListView
}
