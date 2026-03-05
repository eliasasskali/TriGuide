//
// TriGuide 2026
//

import CarbItemsSPM
import Localization
import RaceNutritionSPM
import SwiftUI

public struct AthleteProfileView: View {
    // MARK: - Dependencies

    @ObservedObject private var coordinator: AthleteProfileCoordinator

    // MARK: - Initializer

    init(coordinator: AthleteProfileCoordinator) {
        _coordinator = ObservedObject(wrappedValue: coordinator)
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: coordinator.pathBinding) {
            List {
                NavigationLink(value: AthleteProfileCoordinator.Route.storedPlans) {
                    menuRow(
                        title: Localizables.RaceNutritionResults.storedPlansTitle,
                        systemImage: "list.bullet.clipboard"
                    )
                }

                NavigationLink(value: AthleteProfileCoordinator.Route.carbItems) {
                    menuRow(
                        title: Localizables.CarbItems.title,
                        systemImage: "carrot"
                    )
                }
            }
            .navigationTitle(Localizables.AthleteProfile.title)
            .navigationDestination(for: AthleteProfileCoordinator.Route.self) { route in
                switch route {
                case .storedPlans:
                    coordinator.buildStoredPlansListView()
                case .carbItems:
                    coordinator.buildCarbItemsContentView()
                }
            }
            .navigationDestination(for: RaceNutritionCoordinator.Path.self) { path in
                coordinator.buildRaceNutritionDestination(for: path)
            }
            .navigationDestination(for: CarbItemsCoordinator.Route.self) { route in
                coordinator.buildCarbItemsDestination(for: route)
            }
        }
    }
}

// MARK: - Private methods

private extension AthleteProfileView {
    func menuRow(
        title: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.accentColor)

            Text(title)

            Spacer()
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    AthleteProfileView(coordinator: AthleteProfileCoordinator())
}
