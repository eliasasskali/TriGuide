//
// TriGuide 2025
//

import Foundation

protocol CarbItemsViewFactory {
    @MainActor func buildCarbItemsView() -> CarbItemsView
}
