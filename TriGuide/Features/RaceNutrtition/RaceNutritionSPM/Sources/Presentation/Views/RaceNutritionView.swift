//
// TriGuide 2025
//

import SwiftUI

public struct RaceNutritionView: View {
    @ObservedObject private var viewModel: RaceNutritionViewModel
    @ObservedObject private var coordinator: RaceNutritionCoordinator

    public init(
        viewModel: RaceNutritionViewModel,
        coordinator: RaceNutritionCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        NavigationStack(path: coordinator.pathBinding) {
            VStack {
                Button("Test: Present Carb items") {
                    coordinator.presentCarbItems()
                }
            }
            .sheet(item: coordinator.sheetBinding) { sheet in
                switch sheet {
                case .carbItems:
                    coordinator.buildCarbItemsView()
                }
            }
        }
    }
}

#Preview {

}
