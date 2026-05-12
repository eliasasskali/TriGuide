//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

/// A no-op implementation of `CarbItemsAnalyticsService` that does nothing when its methods are called.
public struct CarbItemsAnalyticsServiceNoOp: CarbItemsAnalyticsService {
    public init() {}
    public func trackListScreenView() {}
    public func trackEditItemScreenView() {}
    public func trackNewItemFormScreenView() {}
    public func trackSearchCarbItem(query _: String) {}
    public func trackCreateCarbItem(item _: CarbItem) {}
    public func trackEditCarbItem(item _: CarbItem) {}
    public func trackDeleteCarbItem(itemId _: String, itemName _: String) {}
    public func trackAddToFavorites(itemId _: String) {}
    public func trackRemoveFromFavorites(itemId _: String) {}
    public func trackContinueSelection(data _: CarbItemsSelectionAnalyticsData, calculationId _: String?) {}
    public func trackItemSelected(item _: CarbItem, quantity _: Double, calculationId _: String?) {}
}
