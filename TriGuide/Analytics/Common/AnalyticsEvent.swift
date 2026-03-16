//
// TriGuide 2026
//

import FirebaseAnalytics

public enum AnalyticsEvent {
    // MARK: - Screens

    public enum Screen {
        public static let raceNutritionCalculator = "race_nutrition_calculator"
        public static let userProfile = "user_profile"
        public static let carbItemsList = "carb_items_list"
        public static let editCarbItem = "edit_carb_item"
        public static let newCarbItemForm = "new_carb_item_form"
    }

    // MARK: - Screen View

    static func screenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
        ])
    }

    // MARK: - Click

    static func click(
        element: String,
        screen: String,
        extraParams: [String: Any]? = nil
    ) {
        var params: [String: Any] = [
            "element": element,
            "screen": screen,
        ]
        extraParams?.forEach { params[$0.key] = $0.value }
        Analytics.logEvent("click", parameters: params)
    }
}
