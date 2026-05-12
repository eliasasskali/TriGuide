//
// TriGuide 2026
//

import Foundation
@testable import RaceNutritionSPM
import TriGuideDomain

actor StoredNutritionPlansDataSourceMock: StoredNutritionPlansDataSource {
    enum MockError: Error {
        case loadFailed
        case saveFailed
    }

    private(set) var loadCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var savedPlansHistory: [[FuelingResult]] = []

    var plansToLoad: [FuelingResult]
    var shouldThrowOnLoad: Bool
    var shouldThrowOnSave: Bool

    init(
        plansToLoad: [FuelingResult] = [],
        shouldThrowOnLoad: Bool = false,
        shouldThrowOnSave: Bool = false
    ) {
        self.plansToLoad = plansToLoad
        self.shouldThrowOnLoad = shouldThrowOnLoad
        self.shouldThrowOnSave = shouldThrowOnSave
    }

    func loadNutritionPlans() async throws -> [FuelingResult] {
        loadCallCount += 1
        if shouldThrowOnLoad {
            throw MockError.loadFailed
        }
        return plansToLoad
    }

    func saveNutritionPlans(_ plans: [FuelingResult]) async throws {
        saveCallCount += 1
        if shouldThrowOnSave {
            throw MockError.saveFailed
        }
        plansToLoad = plans
        savedPlansHistory.append(plans)
    }
}
