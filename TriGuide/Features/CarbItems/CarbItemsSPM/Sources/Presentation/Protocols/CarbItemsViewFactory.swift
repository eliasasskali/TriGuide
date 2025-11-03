//
// TriGuide 2025
//

import Foundation
import FormKit

protocol CarbItemsViewFactory {
    @MainActor func buildCarbItemsView() -> CarbItemsView
    @MainActor func buildCarbItemFormView(
        sections: [FormSection]?,
        existingItem: CarbItem?,
        saveAction: @escaping (CarbItem) -> Void
    ) -> CarbItemFormView
}
