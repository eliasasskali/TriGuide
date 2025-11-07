//
// TriGuide 2025
//

import CarbItemsSPM
import NavigationKit
import SwiftUI

public class RaceNutritionCoordinator: BaseCoordinator<Never, RaceNutritionCoordinator.Sheet, RaceNutritionView> {
    public enum Sheet: Identifiable {
        case carbItems

        public var id: String {
            switch self {
            case .carbItems:
                return "carbItems"
            }
        }
    }

    let factory: RaceNutritionViewFactory
    @Published public var viewModel: RaceNutritionViewModel

    public init(factory: RaceNutritionViewFactory) {
        self.factory = factory
        self.viewModel = factory.buildRaceNutritionViewModel()
        super.init()
    }

    public override func start() -> RaceNutritionView {
        factory.buildRaceNutritionView(
            viewModel: viewModel,
            coordinator: self
        )
    }
}

// MARK: - Navigation

public extension RaceNutritionCoordinator {
    func presentCarbItems() {
        presentSheet(sheet: .carbItems)
    }

    func buildCarbItemsView() -> CarbItemsView? {
        do {
            return try factory.buildCarbItemsCoordinator().start()
        } catch {
            return nil
        }
    }
}
