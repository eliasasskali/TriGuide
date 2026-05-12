//
// TriGuide 2026
//

import Foundation
import Localization
@testable import RaceNutritionSPM
import Testing
import TriGuideDomain

@Suite
@MainActor
struct StoredNutritionPlansListViewModelTests {}

private extension StoredNutritionPlansListViewModelTests {
    func givenSut(
        fetchUseCase: FetchStoredFuelingResultsUseCase = FetchStoredFuelingResultsUseCaseMock(),
        deleteUseCase: DeleteStoredFuelingResultUseCase = DeleteStoredFuelingResultUseCaseMock()
    ) -> StoredNutritionPlansListViewModel {
        StoredNutritionPlansListViewModel(
            fetchStoredFuelingResultsUseCase: fetchUseCase,
            deleteStoredFuelingResultUseCase: deleteUseCase
        )
    }
}

extension StoredNutritionPlansListViewModelTests {
    @Test("Fetch loads and publishes stored plans")
    func storedNutritionPlansListViewModel_whenFetchStoredPlansSucceeds_thenUpdatesPlans() async throws {
        let plan = FuelingResult.buildMock(itemId: "f")
        let fetchUseCase = FetchStoredFuelingResultsUseCaseMock(result: [plan])
        let sut = givenSut(fetchUseCase: fetchUseCase)

        await sut.fetchStoredPlans()

        #expect(sut.isLoading == false)
        #expect(sut.plans == [plan])
        #expect(sut.errorMessage == nil)
    }

    @Test("Fetch failure sets generic error")
    func storedNutritionPlansListViewModel_whenFetchStoredPlansFails_thenSetsGenericError() async throws {
        let fetchUseCase = FetchStoredFuelingResultsUseCaseMock(shouldThrow: true)
        let sut = givenSut(fetchUseCase: fetchUseCase)

        await sut.fetchStoredPlans()

        #expect(sut.isLoading == false)
        #expect(sut.plans.isEmpty)
        #expect(sut.errorMessage == Localizables.Errors.generic)
    }

    @Test("Delete removes selected plans")
    func storedNutritionPlansListViewModel_whenDeletePlanSucceeds_thenRemovesPlanFromList() async throws {
        let first = FuelingResult.buildMock(itemId: "1")
        let second = FuelingResult.buildMock(itemId: "2")
        let fetchUseCase = FetchStoredFuelingResultsUseCaseMock(result: [first, second])
        let deleteUseCase = DeleteStoredFuelingResultUseCaseMock()
        let sut = givenSut(fetchUseCase: fetchUseCase, deleteUseCase: deleteUseCase)

        await sut.fetchStoredPlans()
        await sut.deletePlan(at: IndexSet(integer: 0))

        #expect(sut.plans == [second])
        #expect(await deleteUseCase.deletedPlans == [first])
    }

    @Test("Delete failure keeps plans and publishes delete error")
    func storedNutritionPlansListViewModel_whenDeletePlanFails_thenKeepsPlanAndSetsDeleteError() async throws {
        let first = FuelingResult.buildMock(itemId: "1")
        let fetchUseCase = FetchStoredFuelingResultsUseCaseMock(result: [first])
        let deleteUseCase = DeleteStoredFuelingResultUseCaseMock(shouldThrow: true)
        let sut = givenSut(fetchUseCase: fetchUseCase, deleteUseCase: deleteUseCase)

        await sut.fetchStoredPlans()
        await sut.deletePlan(at: IndexSet(integer: 0))

        #expect(sut.plans == [first])
        #expect(sut.errorMessage == Localizables.Errors.fuelingPlanDeleteFailed)
    }
}

// MARK: - Mocks

private actor FetchStoredFuelingResultsUseCaseMock: FetchStoredFuelingResultsUseCase {
    enum MockError: Error {
        case failed
    }

    let result: [FuelingResult]
    let shouldThrow: Bool

    init(result: [FuelingResult] = [], shouldThrow: Bool = false) {
        self.result = result
        self.shouldThrow = shouldThrow
    }

    func execute() async throws -> [FuelingResult] {
        if shouldThrow {
            throw MockError.failed
        }
        return result
    }
}

private actor DeleteStoredFuelingResultUseCaseMock: DeleteStoredFuelingResultUseCase {
    enum MockError: Error {
        case failed
    }

    private(set) var deletedPlans: [FuelingResult] = []
    let shouldThrow: Bool

    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    func execute(plan: FuelingResult) async throws {
        if shouldThrow {
            throw MockError.failed
        }
        deletedPlans.append(plan)
    }
}
