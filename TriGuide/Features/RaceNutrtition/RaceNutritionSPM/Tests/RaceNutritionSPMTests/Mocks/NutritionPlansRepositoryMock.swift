//
// TriGuide 2026
//

import Foundation
@testable import RaceNutritionSPM
import TriGuideDomain

actor NutritionPlansRepositoryMock: NutritionPlansRepository {
    enum MockError: Error {
        case fetchFailed
        case addFailed
        case deleteFailed
    }

    private(set) var fetchCallCount = 0
    private(set) var addCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var addedPlans: [(plan: FuelingResult, name: String)] = []
    private(set) var deletedPlans: [FuelingResult] = []

    var fetchResult: [FuelingResult]
    var shouldThrowOnFetch: Bool
    var shouldThrowOnAdd: Bool
    var shouldThrowOnDelete: Bool

    init(
        fetchResult: [FuelingResult] = [],
        shouldThrowOnFetch: Bool = false,
        shouldThrowOnAdd: Bool = false,
        shouldThrowOnDelete: Bool = false
    ) {
        self.fetchResult = fetchResult
        self.shouldThrowOnFetch = shouldThrowOnFetch
        self.shouldThrowOnAdd = shouldThrowOnAdd
        self.shouldThrowOnDelete = shouldThrowOnDelete
    }

    func fetchNutritionPlans() async throws -> [FuelingResult] {
        fetchCallCount += 1
        if shouldThrowOnFetch {
            throw MockError.fetchFailed
        }
        return fetchResult
    }

    func addNutritionPlan(_ plan: FuelingResult, name: String) async throws {
        addCallCount += 1
        if shouldThrowOnAdd {
            throw MockError.addFailed
        }
        addedPlans.append((plan: plan, name: name))
    }

    func deleteNutritionPlan(_ plan: FuelingResult) async throws {
        deleteCallCount += 1
        if shouldThrowOnDelete {
            throw MockError.deleteFailed
        }
        deletedPlans.append(plan)
    }
}
