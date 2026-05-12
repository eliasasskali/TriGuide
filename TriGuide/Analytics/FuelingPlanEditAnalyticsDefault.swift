//
// TriGuide 2026
//

import FirebaseAnalytics
import RaceNutritionSPM

struct FuelingPlanEditAnalyticsDefault: FuelingPlanEditAnalyticsService {
    // MARK: - Constants

    private enum Constants {
        static let screenName = AnalyticsEvent.Screen.fuelingPlanEdit

        // MARK: - Event names

        static let planEditedEventName = "fueling_plan_edited"
    }

    // MARK: - FuelingPlanEditAnalyticsService

    func trackScreenView() {
        AnalyticsEvent.screenView(screenName: Constants.screenName)
    }

    func trackPlanEdited(data: FuelingPlanEditAnalyticsData) {
        Analytics.logEvent(
            Constants.planEditedEventName,
            parameters: [
                "screen": Constants.screenName,
                "calculation_id": data.calculationId as Any,
                "items_moved_count": data.itemsMovedCount,
                "average_shift_seconds": data.averageShiftSeconds,
                "max_shift_seconds": data.maxShiftSeconds,
            ]
        )
    }
}
