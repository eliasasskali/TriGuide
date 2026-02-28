//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

public protocol NutritionPlansRepository: Sendable {
    func fetchNutritionPlans() async throws -> [FuelingResult]
    func addNutritionPlan(_ plan: FuelingResult, name: String) async throws
    func deleteNutritionPlan(_ plan: FuelingResult) async throws
}
