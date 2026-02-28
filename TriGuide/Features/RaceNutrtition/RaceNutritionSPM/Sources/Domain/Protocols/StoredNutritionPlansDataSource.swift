//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

public protocol StoredNutritionPlansDataSource: Sendable {
    func loadNutritionPlans() async throws -> [FuelingResult]
    func saveNutritionPlans(_ plans: [FuelingResult]) async throws
}
