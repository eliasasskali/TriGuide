//
// TriGuide 2025
//

import Foundation
import FormKit

public protocol CarbItemsViewFactory {
    @MainActor func buildCarbItemsView(
        viewModel: CarbItemsViewModel,
        coordinator: CarbItemsCoordinator
    ) -> CarbItemsView
    @MainActor func buildCarbItemsViewModel() -> CarbItemsViewModel
    @MainActor func buildCarbItemFormView(
        sections: [FormSection]?,
        existingItem: CarbItem?,
        saveAction: @escaping (CarbItem) -> Void
    ) -> CarbItemFormView
}
