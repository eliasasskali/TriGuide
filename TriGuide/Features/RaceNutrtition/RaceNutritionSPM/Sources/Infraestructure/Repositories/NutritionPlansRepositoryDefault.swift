//
// TriGuide 2026
//

import Foundation
import TriGuideDomain

actor NutritionPlansRepositoryDefault: NutritionPlansRepository {
    // MARK: - RepositoryError

    enum RepositoryError: Error, Equatable {
        case duplicateNutritionPlan
        case saveFailed
        case deleteFailed

        static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {
            switch (lhs, rhs) {
            case (.duplicateNutritionPlan, .duplicateNutritionPlan),
                 (.saveFailed, .saveFailed),
                 (.deleteFailed, .deleteFailed):
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    private let dataSource: StoredNutritionPlansDataSource

    // MARK: - Properties

    private var nutritionPlans: [FuelingResult] = []

    // MARK: - Initializer

    init(nutritionPlansDataSource: StoredNutritionPlansDataSource) {
        dataSource = nutritionPlansDataSource
    }

    // MARK: - NutritionPlansRepository

    func fetchNutritionPlans() async throws -> [FuelingResult] {
        nutritionPlans = try await dataSource.loadNutritionPlans()
        return nutritionPlans
    }

    func addNutritionPlan(
        _ plan: FuelingResult,
        name: String
    ) async throws {
        nutritionPlans = try await dataSource.loadNutritionPlans()
        let planWithName = FuelingResult(
            name: name,
            timeLine: plan.timeLine,
            totalCarbsTarget: plan.totalCarbsTarget,
            duration: plan.duration,
            selectedItems: plan.selectedItems,
            hourlyBreakdown: plan.hourlyBreakdown
        )
        guard !nutritionPlans.contains(where: { $0 == planWithName }) else {
            throw RepositoryError.duplicateNutritionPlan
        }
        nutritionPlans.append(planWithName)
        do {
            try await dataSource.saveNutritionPlans(nutritionPlans)
        } catch {
            throw RepositoryError.saveFailed
        }
    }

    func replaceNutritionPlan(
        _ oldPlan: FuelingResult,
        with newPlan: FuelingResult,
        name: String
    ) async throws {
        nutritionPlans = try await dataSource.loadNutritionPlans()
        let planWithName = FuelingResult(
            name: name,
            timeLine: newPlan.timeLine,
            totalCarbsTarget: newPlan.totalCarbsTarget,
            duration: newPlan.duration,
            selectedItems: newPlan.selectedItems,
            hourlyBreakdown: newPlan.hourlyBreakdown
        )
        guard let index = nutritionPlans.firstIndex(where: { $0 == oldPlan }) else {
            throw RepositoryError.saveFailed
        }
        nutritionPlans[index] = planWithName
        do {
            try await dataSource.saveNutritionPlans(nutritionPlans)
        } catch {
            throw RepositoryError.saveFailed
        }
    }

    func deleteNutritionPlan(_ plan: FuelingResult) async throws {
        nutritionPlans = try await dataSource.loadNutritionPlans()
        nutritionPlans.removeAll { $0 == plan }
        do {
            try await dataSource.saveNutritionPlans(nutritionPlans)
        } catch {
            throw RepositoryError.deleteFailed
        }
    }
}
