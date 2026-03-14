//
// TriGuide 2025
//

import CarbItemsSPM
import NavigationKit
import SwiftUI
import TriGuideDomain

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
            case let .carbItems(totalGrams): return "carbItems_\(totalGrams)"
            }
        }
    }

    // MARK: - Dependencies

    @Published public var viewModel: RaceNutritionViewModel
    @Published var showSavedPlanToast = false
    private let factory: RaceNutritionViewFactory
    private var carbItemsCoordinator: CarbItemsCoordinator?
    private let raceNutritionResultViewModel: RaceNutritionResultViewModel
    private var originalStoredPlan: FuelingResult?
    public var onPlanUpdated: (() -> Void)?

    // MARK: - Initializer

    public init(factory: RaceNutritionViewFactory) {
        self.factory = factory
        raceNutritionResultViewModel = factory.buildRaceNutritionResultViewModel()
        viewModel = factory.buildRaceNutritionViewModel()
        super.init()
    }

    // MARK: - Overrides

    override public func start() -> RaceNutritionView {
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

    func resetAndPopToRoot() {
        popToRoot()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.viewModel.reset()
            self?.showSavedPlanToast = true
        }
    }

    func pushFuelingPlanFullView() {
        push(.fuelingPlanFullView)
    }

    func openStoredFuelingResult(_ result: FuelingResult) {
        originalStoredPlan = result
        viewModel.fuelingResult = result
        pushRaceNutritionResultView()
    }

    func buildRaceNutritionResultDestination() -> RaceNutritionResultView? {
        guard let fuelingResult = viewModel.fuelingResult else { return nil }

        let binding = Binding<FuelingResult>(
            get: { self.viewModel.fuelingResult ?? fuelingResult },
            set: { self.viewModel.fuelingResult = $0 }
        )

        return factory.buildRaceNutritionResultView(
            coordinator: self,
            viewModel: raceNutritionResultViewModel,
            showSaveButton: originalStoredPlan == nil,
            fuelingResult: binding
        )
    }

    func buildFuelingPlanEditDestination() -> AnyView {
        guard let fuelingResult = viewModel.fuelingResult else {
            return AnyView(EmptyView())
        }

        let binding = Binding<FuelingResult>(
            get: { self.viewModel.fuelingResult ?? fuelingResult },
            set: { self.viewModel.fuelingResult = $0 }
        )

        return AnyView(
            FuelingPlanEditView(
                result: binding,
                showNameEditor: originalStoredPlan != nil
            ) { [weak self] updatedPlan in
                guard let self, let originalStoredPlan else { return true }
                let saved = await raceNutritionResultViewModel.replaceFuelingPlan(
                    oldPlan: originalStoredPlan,
                    updatedPlan: updatedPlan
                )
                if saved {
                    self.originalStoredPlan = updatedPlan
                    self.onPlanUpdated?()
                }
                return saved
            }
        )
    }

    func buildCarbItemsView(totalCarbGrams: Double) -> CarbItemsView? {
        do {
            guard let carbItemsCoordinator else {
                carbItemsCoordinator = try factory.buildCarbItemsCoordinator(
                    totalCarbGrams: totalCarbGrams,
                    onCompleteSelection: { [weak self] carbItemsSelection in
                        guard let self else { return }
                        Task { @MainActor [weak self] in
                            guard let self,
                                  let _ = await viewModel.calculateFuelingAsync(from: carbItemsSelection)
                            else { return }
                            originalStoredPlan = nil
                            pushRaceNutritionResultView()
                        }
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
