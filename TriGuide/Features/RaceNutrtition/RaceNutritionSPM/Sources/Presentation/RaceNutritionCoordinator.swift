//
// TriGuide 2025
//

import CarbItemsSPM
import NavigationKit
import SwiftUI

public class RaceNutritionCoordinator: BaseCoordinator<RaceNutritionCoordinator.Path, RaceNutritionCoordinator.Sheet, RaceNutritionView> {

    // MARK: - Nested Types

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

    // MARK: - Dependencies

    @Published public var viewModel: RaceNutritionViewModel
    private let factory: RaceNutritionViewFactory
    private var carbItemsCoordinator: CarbItemsCoordinator?

    // MARK: - Initializer

    public init(factory: RaceNutritionViewFactory) {
        self.factory = factory
        self.viewModel = factory.buildRaceNutritionViewModel()
        super.init()
    }

    // MARK: - Overrides

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

    func pushRaceNutritionResultView() {
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
                              let _ = viewModel.calculateFueling(from: carbItemsSelection)
                        else { return }
                        pushRaceNutritionResultView()
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
