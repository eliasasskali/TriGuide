//
// TriGuide 2026
//

import Foundation
import NavigationKit

public class StoredNutritionPlansCoordinator: BaseCoordinator<Never, Never, StoredNutritionPlansListView> {
    // MARK: - Dependencies

    private let factory: RaceNutritionViewFactory
    private let raceNutritionCoordinator: RaceNutritionCoordinator?
    public let viewModel: StoredNutritionPlansListViewModel

    // MARK: - Initializer

    public init(
        factory: RaceNutritionViewFactory,
        raceNutritionCoordinator: RaceNutritionCoordinator? = nil
    ) {
        self.factory = factory
        self.raceNutritionCoordinator = raceNutritionCoordinator
        viewModel = factory.buildStoredNutritionPlansListViewModel()
        super.init()
    }

    // MARK: - BaseCoordinator

    override public func start() -> StoredNutritionPlansListView {
        StoredNutritionPlansListView(
            viewModel: viewModel,
            coordinator: raceNutritionCoordinator
        )
    }
}
