//
// TriGuide 2026
//

import Foundation
import NavigationKit

public class StoredNutritionPlansCoordinator: BaseCoordinator<Never, Never, StoredNutritionPlansListView> {
    // MARK: - Dependencies

    private let factory: RaceNutritionViewFactory

    // MARK: - Initializer

    public init(factory: RaceNutritionViewFactory) {
        self.factory = factory
        super.init()
    }

    // MARK: - BaseCoordinator

    override public func start() -> StoredNutritionPlansListView {
        factory.buildStoredNutritionPlansListView()
    }
}
