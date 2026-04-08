//
// TriGuide 2026
//

import FirebaseAnalytics
import RaceNutritionSPM

struct RaceNutritionResultAnalyticsDefault: RaceNutritionResultAnalyticsService {
    // MARK: - Constants

    private enum Constants {
        static let screenName = AnalyticsEvent.Screen.raceNutritionResult

        // MARK: - Click elements

        static let savePlanButtonElement = "save_plan_button"
        static let editPlanButtonElement = "edit_plan_button"
        static let toggleSelectedItemsElement = "toggle_selected_items"

        // MARK: - Event names

        static let fuelingResultGeneratedEventName = "fueling_result_generated"
        static let planSavedEventName = "plan_saved"
    }

    // MARK: - RaceNutritionResultAnalyticsService

    func trackScreenView() {
        AnalyticsEvent.screenView(screenName: Constants.screenName)
    }

    func trackFuelingResultGenerated(data: RaceNutritionResultAnalyticsData) {
        Analytics.logEvent(
            Constants.fuelingResultGeneratedEventName,
            parameters: buildResultParameters(from: data)
        )
    }

    func trackSavePlanClick() {
        AnalyticsEvent.click(
            element: Constants.savePlanButtonElement,
            screen: Constants.screenName
        )
    }

    func trackPlanSaved(planName: String, data: RaceNutritionResultAnalyticsData) {
        var params = buildResultParameters(from: data)
        params["plan_name"] = planName
        Analytics.logEvent(
            Constants.planSavedEventName,
            parameters: params
        )
    }

    func trackEditPlanClick() {
        AnalyticsEvent.click(
            element: Constants.editPlanButtonElement,
            screen: Constants.screenName
        )
    }

    func trackToggleSelectedItems(expanded: Bool) {
        AnalyticsEvent.click(
            element: Constants.toggleSelectedItemsElement,
            screen: Constants.screenName,
            extraParams: ["expanded": expanded]
        )
    }
}

// MARK: - Private

private extension RaceNutritionResultAnalyticsDefault {
    func buildResultParameters(from data: RaceNutritionResultAnalyticsData) -> [String: Any] {
        [
            "screen": Constants.screenName,
            "calculation_id": data.calculationId as Any,
            "duration_seconds": data.durationSeconds,
            "total_carbs_target": data.totalCarbsTarget,
            "total_selected_carbs": data.totalSelectedCarbs,
            "carb_target_per_hour": data.carbTargetPerHour,
            "actual_carbs_per_hour": data.actualCarbsPerHour,
            "carb_deficit_ratio": data.carbDeficitRatio,
            "total_timeline_events": data.totalTimelineEvents,
            "total_caffeine_mg": data.totalCaffeineMg,
            "total_water_volume_ml": data.totalWaterVolumeML,
            "first_caffeine_time_seconds": data.firstCaffeineTimeSeconds as Any,
            "drink_coverage_ratio": data.drinkCoverageRatio,
            "carb_distribution_variance": data.carbDistributionVariance,
            "was_edited": data.wasEdited,
        ]
    }
}
