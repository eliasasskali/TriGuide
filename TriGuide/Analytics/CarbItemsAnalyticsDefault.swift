//
// TriGuide 2026
//

import CarbItemsSPM
import FirebaseAnalytics
import TriGuideDomain

struct CarbItemsAnalyticsDefault: CarbItemsAnalyticsService {
    // MARK: - Constants

    private enum Constants {
        // Click elements
        static let searchAction = "search_carb_item"
        static let addToFavoritesElement = "add_to_favorites"
        static let removeFromFavoritesElement = "remove_from_favorites"
        static let continueSelectionElement = "continue_selection"

        // Event names
        static let createCarbItemEvent = "create_carb_item"
        static let editCarbItemEvent = "edit_carb_item"
        static let deleteCarbItemEvent = "delete_carb_item"
    }

    // MARK: - Screen Names

    private let listScreenName: String
    private let editItemScreenName: String
    private let newItemFormScreenName: String

    // MARK: - Initializer

    init(originScreen: CarbItemsOriginScreen) {
        let base = originScreen.rawValue + "/" + AnalyticsEvent.Screen.carbItemsList
        listScreenName = base
        editItemScreenName = base + "/" + AnalyticsEvent.Screen.editCarbItem
        newItemFormScreenName = base + "/" + AnalyticsEvent.Screen.newCarbItemForm
    }

    // MARK: - Screen Views

    func trackListScreenView() {
        AnalyticsEvent.screenView(screenName: listScreenName)
    }

    func trackEditItemScreenView() {
        AnalyticsEvent.screenView(screenName: editItemScreenName)
    }

    func trackNewItemFormScreenView() {
        AnalyticsEvent.screenView(screenName: newItemFormScreenName)
    }

    // MARK: - Search

    func trackSearchCarbItem(query: String) {
        Analytics.logEvent("search", parameters: [
            "screen": listScreenName,
            "action": Constants.searchAction,
            "value": query,
        ])
    }

    // MARK: - CRUD

    func trackCreateCarbItem(item: CarbItem) {
        Analytics.logEvent(Constants.createCarbItemEvent, parameters: [
            "screen": newItemFormScreenName,
            "item_id": item.id,
            "item_name": item.name,
            "carbs": item.gramsOfCarbs,
            "caffeine": item.caffeine as Any,
            "sodium": item.sodium as Any,
            "water_volume_ml": item.waterVolumeML as Any,
            "type": item.type.rawValue,
            "brand": item.brand ?? "",
        ])
    }

    func trackEditCarbItem(item: CarbItem) {
        Analytics.logEvent(Constants.editCarbItemEvent, parameters: [
            "screen": editItemScreenName,
            "item_id": item.id,
            "item_name": item.name,
            "carbs": item.gramsOfCarbs,
            "caffeine": item.caffeine as Any,
            "sodium": item.sodium as Any,
            "water_volume_ml": item.waterVolumeML as Any,
            "type": item.type.rawValue,
            "brand": item.brand ?? "",
        ])
    }

    func trackDeleteCarbItem(itemId: String, itemName: String) {
        Analytics.logEvent(Constants.deleteCarbItemEvent, parameters: [
            "screen": listScreenName,
            "item_id": itemId,
            "item_name": itemName,
        ])
    }

    // MARK: - Favorites

    func trackAddToFavorites(itemId: String) {
        AnalyticsEvent.click(
            element: Constants.addToFavoritesElement,
            screen: listScreenName,
            extraParams: ["item_id": itemId]
        )
    }

    func trackRemoveFromFavorites(itemId: String) {
        AnalyticsEvent.click(
            element: Constants.removeFromFavoritesElement,
            screen: listScreenName,
            extraParams: ["item_id": itemId]
        )
    }

    // MARK: - Selection

    func trackContinueSelection(data: CarbItemsSelectionAnalyticsData) {
        let userItemsInfo: [[String: Any]] = data.userCarbItems.map { item in
            [
                "id": item.id,
                "name": item.name,
                "carbs": item.gramsOfCarbs,
                "type": item.type.rawValue,
                "brand": item.brand ?? "",
            ]
        }
        let userItemsJSON: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: userItemsInfo),
           let jsonString = String(data: jsonData, encoding: .utf8)
        {
            userItemsJSON = jsonString
        } else {
            userItemsJSON = "[]"
        }

        Analytics.logEvent(Constants.continueSelectionElement, parameters: [
            "screen": listScreenName,
            "remote_carb_item_ids": data.remoteCarbItemIds,
            "user_carb_items": userItemsJSON,
            "total_carbs_selected": data.totalCarbsSelected,
            "estimated_total_carbs": data.estimatedTotalCarbs,
        ])
    }
}
