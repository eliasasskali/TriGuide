//
// TriGuide 2026
//

import FirebaseAnalytics

public enum AnalyticsEvent {
    // MARK: - Screens

    public enum Screen {
        public static let raceNutritionCalculator = "race_nutrition_calculator"
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
