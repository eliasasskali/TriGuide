//
// TriGuide 2025
//

import CarbItemsSPM
import NavigationKit
import SwiftUI
import TriGuideDomain

public class RaceNutritionCoordinator: BaseCoordinator<RaceNutritionCoordinator.Path, RaceNutritionCoordinator.Sheet, RaceNutritionView> {
    public enum Path: Hashable {
        case raceNutritionResult
        case fuelingPlanFullView
    }

    public enum Sheet: Identifiable, Equatable {
        case carbItems(totalGrams: Double)

        public var id: String {
            switch self {
            case .carbItems(let totalGrams):
                return "carbItems_\(totalGrams)"
            }
        }
    }

    let factory: RaceNutritionViewFactory
    @Published public var viewModel: RaceNutritionViewModel

    private var carbItemsCoordinator: CarbItemsCoordinator?

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
    func presentCarbItems(totalCarbGrams: Double) {
        presentSheet(sheet: .carbItems(totalGrams: totalCarbGrams))
    }

    func pushRaceNutritionResultView(result: FuelingResult) {
        push(.raceNutritionResult)
    }

    func pushFuelingPlanFullView() {
        push(.fuelingPlanFullView)
    }
    
    func buildCarbItemsView(totalCarbGrams: Double) -> CarbItemsView? {
        do {
            guard let carbItemsCoordinator else {
                carbItemsCoordinator = try factory.buildCarbItemsCoordinator(
                    totalCarbGrams: totalCarbGrams,
                    onCompleteSelection: { [weak self] carbItemsSelection in
                        guard let self,
                              let result = viewModel.calculateFueling(from: carbItemsSelection)
                        else { return }
                        pushRaceNutritionResultView(result: result)
                    }
                )
                return carbItemsCoordinator?.start()
            }
            carbItemsCoordinator.viewModel.totalCarbGrams = totalCarbGrams
            return carbItemsCoordinator.start()
        } catch {
            return nil
        }
    }
}
