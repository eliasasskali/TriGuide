//
// TriGuide 2026
//

@testable import RaceNutritionSPM
import Testing
import TriGuideDomain

@Suite
struct NutritionPlansRepositoryDefaultTests {}

private extension NutritionPlansRepositoryDefaultTests {
    func givenSut(
        plansToLoad: [FuelingResult] = [],
        shouldThrowOnLoad: Bool = false,
        shouldThrowOnSave: Bool = false
    ) -> (sut: NutritionPlansRepositoryDefault, dataSource: StoredNutritionPlansDataSourceMock) {
        let dataSource = StoredNutritionPlansDataSourceMock(
            plansToLoad: plansToLoad,
            shouldThrowOnLoad: shouldThrowOnLoad,
            shouldThrowOnSave: shouldThrowOnSave
        )
        let sut = NutritionPlansRepositoryDefault(nutritionPlansDataSource: dataSource)
        return (sut, dataSource)
    }
}

extension NutritionPlansRepositoryDefaultTests {
    @Test("Fetch returns plans loaded from data source")
    func nutritionPlansRepositoryDefault_whenFetchNutritionPlans_thenReturnsLoadedPlans() async throws {
        let plan = FuelingResult.buildMock(name: "Plan A", itemId: "a")
        let (sut, dataSource) = givenSut(plansToLoad: [plan])

        let plans = try await sut.fetchNutritionPlans()

        #expect(plans == [plan])
        #expect(await dataSource.loadCallCount == 1)
    }

    @Test("Add plan persists with provided name")
    func nutritionPlansRepositoryDefault_whenAddNutritionPlan_thenPersistsPlanWithProvidedName() async throws {
        let rawPlan = FuelingResult.buildMock(name: nil, itemId: "a")
        let (sut, dataSource) = givenSut()

        try await sut.addNutritionPlan(rawPlan, name: "Race Day")

        let savedHistory = await dataSource.savedPlansHistory
        #expect(savedHistory.count == 1)
        #expect(savedHistory[0].count == 1)
        #expect(savedHistory[0][0].name == "Race Day")
    }

    @Test("Adding duplicate plan throws duplicate error")
    func nutritionPlansRepositoryDefault_whenAddDuplicateNutritionPlan_thenThrowsDuplicateError() async throws {
        let existing = FuelingResult.buildMock(name: "Existing", itemId: "dup")
        let duplicateContent = FuelingResult.buildMock(name: nil, itemId: "dup")
        let (sut, _) = givenSut(plansToLoad: [existing])

        do {
            try await sut.addNutritionPlan(duplicateContent, name: "Other Name")
            Issue.record("Expected duplicateNutritionPlan error")
        } catch let error as NutritionPlansRepositoryDefault.RepositoryError {
            #expect(error == .duplicateNutritionPlan)
        }
    }

    @Test("Add maps data source save errors")
    func nutritionPlansRepositoryDefault_whenAddNutritionPlanAndSaveFails_thenThrowsSaveFailed() async throws {
        let plan = FuelingResult.buildMock(itemId: "x")
        let (sut, _) = givenSut(shouldThrowOnSave: true)

        do {
            try await sut.addNutritionPlan(plan, name: "Plan")
            Issue.record("Expected saveFailed error")
        } catch let error as NutritionPlansRepositoryDefault.RepositoryError {
            #expect(error == .saveFailed)
        }
    }

    @Test("Delete loads persisted plans and removes matching one")
    func nutritionPlansRepositoryDefault_whenDeleteNutritionPlan_thenRemovesMatchingPlan() async throws {
        let toDelete = FuelingResult.buildMock(name: "Delete", itemId: "d")
        let remaining = FuelingResult.buildMock(name: "Keep", itemId: "k")
        let (sut, dataSource) = givenSut(plansToLoad: [toDelete, remaining])

        try await sut.deleteNutritionPlan(toDelete)

        let savedHistory = await dataSource.savedPlansHistory
        #expect(savedHistory.count == 1)
        #expect(savedHistory[0] == [remaining])
        #expect(await dataSource.loadCallCount == 1)
    }

    @Test("Delete maps data source save errors")
    func nutritionPlansRepositoryDefault_whenDeleteNutritionPlanAndSaveFails_thenThrowsDeleteFailed() async throws {
        let plan = FuelingResult.buildMock(itemId: "x")
        let (sut, _) = givenSut(plansToLoad: [plan], shouldThrowOnSave: true)

        do {
            try await sut.deleteNutritionPlan(plan)
            Issue.record("Expected deleteFailed error")
        } catch let error as NutritionPlansRepositoryDefault.RepositoryError {
            #expect(error == .deleteFailed)
        }
    }
}
