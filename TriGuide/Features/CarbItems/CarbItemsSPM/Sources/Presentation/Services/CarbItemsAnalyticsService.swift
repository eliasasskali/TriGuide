//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

// MARK: - CarbItemsOriginScreen

public enum CarbItemsOriginScreen: String, Sendable {
    case raceNutritionCalculator = "race_nutrition_calculator"
    case userProfile = "user_profile"
}

// MARK: - CarbItemsSelectionAnalyticsData

public struct CarbItemsSelectionAnalyticsData {
    public let remoteCarbItemIds: [String]
    public let userCarbItems: [CarbItem]
    public let totalCarbsSelected: Double
    public let estimatedTotalCarbs: Double

    public init(
        remoteCarbItemIds: [String],
        userCarbItems: [CarbItem],
        totalCarbsSelected: Double,
        estimatedTotalCarbs: Double
    ) {
        self.remoteCarbItemIds = remoteCarbItemIds
        self.userCarbItems = userCarbItems
        self.totalCarbsSelected = totalCarbsSelected
        self.estimatedTotalCarbs = estimatedTotalCarbs
    }
}

// MARK: - CarbItemsAnalyticsService

public protocol CarbItemsAnalyticsService {
    func trackListScreenView()
    func trackEditItemScreenView()
    func trackNewItemFormScreenView()
    func trackSearchCarbItem(query: String)
    func trackCreateCarbItem(item: CarbItem)
    func trackEditCarbItem(item: CarbItem)
    func trackDeleteCarbItem(itemId: String, itemName: String)
    func trackAddToFavorites(itemId: String)
    func trackRemoveFromFavorites(itemId: String)
    func trackContinueSelection(data: CarbItemsSelectionAnalyticsData)
}
