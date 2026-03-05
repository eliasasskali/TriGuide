//
// TriGuide 2026
//

import CarbItemsSPM
import Foundation
import Localization
import NavigationKit
import RaceNutritionSPM
import SwiftUI

@MainActor
public final class AthleteProfileCoordinator: BaseCoordinator<AthleteProfileCoordinator.Route, Never, AthleteProfileView> {
    // MARK: - Route

    public enum Route: Hashable {
        case storedPlans
        case carbItems
    }

    // MARK: - Dependencies

    private let raceNutritionFactory: RaceNutritionViewFactoryDefault
    let raceNutritionCoordinator: RaceNutritionCoordinator
    private let storedPlansCoordinator: StoredNutritionPlansCoordinator
    let carbItemsCoordinator: CarbItemsCoordinator?

    // MARK: - Initializer

    public init(raceNutritionFactory: RaceNutritionViewFactoryDefault = .init(dependencies: .init())) {
        self.raceNutritionFactory = raceNutritionFactory
        raceNutritionCoordinator = RaceNutritionCoordinator(factory: raceNutritionFactory)
        storedPlansCoordinator = StoredNutritionPlansCoordinator(
            factory: raceNutritionFactory,
            raceNutritionCoordinator: raceNutritionCoordinator
        )
        if let carbFactory = try? CarbItemsViewFactoryDefault(dependencies: .init()) {
            carbItemsCoordinator = CarbItemsCoordinator(factory: carbFactory)
        } else {
            carbItemsCoordinator = nil
        }
        super.init()

        // Redirect sub-coordinator pushes to this coordinator's single NavigationStack path
        raceNutritionCoordinator.externalPushHandler = { [weak self] path in
            self?.pushAny(path)
        }
        carbItemsCoordinator?.externalPushHandler = { [weak self] route in
            self?.pushAny(route)
        }
    }

    // MARK: - BaseCoordinator

    override public func start() -> AthleteProfileView {
        AthleteProfileView(coordinator: self)
    }
}

// MARK: - Destination Builders

public extension AthleteProfileCoordinator {
    func buildStoredPlansListView() -> StoredNutritionPlansListView {
        storedPlansCoordinator.start()
    }

    @ViewBuilder
    func buildCarbItemsContentView() -> some View {
        if let carbItemsCoordinator {
            CarbItemsView(
                viewModel: carbItemsCoordinator.viewModel,
                coordinator: carbItemsCoordinator,
                embedded: true
            )
        } else {
            Text(Localizables.Errors.generic)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    func buildRaceNutritionDestination(for path: RaceNutritionCoordinator.Path) -> some View {
        switch path {
        case .raceNutritionResult:
            raceNutritionCoordinator.buildRaceNutritionResultDestination()

        case .fuelingPlanFullView:
            raceNutritionCoordinator.buildFuelingPlanEditDestination()
        }
    }

    @ViewBuilder
    func buildCarbItemsDestination(for route: CarbItemsCoordinator.Route) -> some View {
        switch route {
        case let .form(existing):
            carbItemsCoordinator?.buildFormView(for: existing)
        }
    }
}
