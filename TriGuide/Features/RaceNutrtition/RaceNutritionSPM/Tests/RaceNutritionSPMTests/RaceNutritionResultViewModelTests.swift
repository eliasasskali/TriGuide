//
// TriGuide 2026
//

import Localization
@testable import RaceNutritionSPM
import Testing
import TriGuideDomain

@Suite
@MainActor
struct RaceNutritionResultViewModelTests {}

private extension RaceNutritionResultViewModelTests {
    func givenSut(
        saveUseCase: SaveFuelingPlanUseCase = SaveFuelingPlanUseCaseMock(),
        deleteUseCase: DeleteStoredFuelingResultUseCase = DeleteStoredFuelingResultUseCaseMock()
    ) -> RaceNutritionResultViewModel {
        RaceNutritionResultViewModel(
            saveFuelingPlanUseCase: saveUseCase,
            deleteStoredFuelingResultUseCase: deleteUseCase
        )
    }
}

extension RaceNutritionResultViewModelTests {
    @Test("Save delegates with provided plan name")
    func raceNutritionResultViewModel_whenSaveFuelingPlan_thenDelegatesToSaveUseCase() async {
        let saveUseCase = SaveFuelingPlanUseCaseMock()
        let sut = givenSut(saveUseCase: saveUseCase)
        let plan = FuelingResult.buildMock(itemId: "save")

        let saved = await sut.saveFuelingPlan(plan, planName: "Plan A")

        #expect(saved)
        let calls = await saveUseCase.savedCalls
        #expect(calls.count == 1)
        #expect(calls[0].plan == plan)
        #expect(calls[0].planName == "Plan A")
    }

    @Test("Replace deletes old and saves updated with updated name")
    func raceNutritionResultViewModel_whenReplaceWithUpdatedName_thenDeletesAndSavesWithUpdatedName() async {
        let saveUseCase = SaveFuelingPlanUseCaseMock()
        let deleteUseCase = DeleteStoredFuelingResultUseCaseMock()
        let sut = givenSut(saveUseCase: saveUseCase, deleteUseCase: deleteUseCase)

        let oldPlan = FuelingResult.buildMock(name: "Old Name", itemId: "old")
        let updatedPlan = FuelingResult.buildMock(name: "New Name", itemId: "updated")

        let replaced = await sut.replaceFuelingPlan(oldPlan: oldPlan, updatedPlan: updatedPlan)

        #expect(replaced)
        #expect(await deleteUseCase.deletedPlans == [oldPlan])
        let calls = await saveUseCase.savedCalls
        #expect(calls.count == 1)
        #expect(calls[0].plan == updatedPlan)
        #expect(calls[0].planName == "New Name")
    }

    @Test("Replace uses old plan name when updated name is missing")
    func raceNutritionResultViewModel_whenReplaceWithoutUpdatedName_thenUsesOldPlanName() async {
        let saveUseCase = SaveFuelingPlanUseCaseMock()
        let sut = givenSut(saveUseCase: saveUseCase)

        let oldPlan = FuelingResult.buildMock(name: "Stored Name", itemId: "old")
        let updatedPlan = FuelingResult.buildMock(name: nil, itemId: "updated")

        let replaced = await sut.replaceFuelingPlan(oldPlan: oldPlan, updatedPlan: updatedPlan)

        #expect(replaced)
        let calls = await saveUseCase.savedCalls
        #expect(calls.count == 1)
        #expect(calls[0].planName == "Stored Name")
    }

    @Test("Replace uses unnamed fallback when both names are missing")
    func raceNutritionResultViewModel_whenReplaceWithoutAnyName_thenUsesUnnamedFallback() async {
        let saveUseCase = SaveFuelingPlanUseCaseMock()
        let sut = givenSut(saveUseCase: saveUseCase)

        let oldPlan = FuelingResult.buildMock(name: nil, itemId: "old")
        let updatedPlan = FuelingResult.buildMock(name: nil, itemId: "updated")

        let replaced = await sut.replaceFuelingPlan(oldPlan: oldPlan, updatedPlan: updatedPlan)

        #expect(replaced)
        let calls = await saveUseCase.savedCalls
        #expect(calls.count == 1)
        #expect(calls[0].planName == Localizables.RaceNutritionResults.storedPlansItemUnnamedPlan)
    }

    @Test("Replace returns false and does not save when delete fails")
    func raceNutritionResultViewModel_whenReplaceDeleteFails_thenReturnsFalseAndSkipsSave() async {
        let saveUseCase = SaveFuelingPlanUseCaseMock()
        let deleteUseCase = DeleteStoredFuelingResultUseCaseMock(
            executeError: NutritionPlansRepositoryDefault.RepositoryError.deleteFailed
        )
        let sut = givenSut(saveUseCase: saveUseCase, deleteUseCase: deleteUseCase)

        let replaced = await sut.replaceFuelingPlan(
            oldPlan: FuelingResult.buildMock(name: "Old", itemId: "old"),
            updatedPlan: FuelingResult.buildMock(name: "New", itemId: "new")
        )

        #expect(!replaced)
        #expect(await saveUseCase.savedCalls.isEmpty)
        #expect(sut.errorMessage == Localizables.Errors.generic)
    }

    @Test("Replace returns false and maps save failure")
    func raceNutritionResultViewModel_whenReplaceSaveFails_thenReturnsFalseAndSetsSaveError() async {
        let saveUseCase = SaveFuelingPlanUseCaseMock(
            executeError: NutritionPlansRepositoryDefault.RepositoryError.saveFailed
        )
        let deleteUseCase = DeleteStoredFuelingResultUseCaseMock()
        let sut = givenSut(saveUseCase: saveUseCase, deleteUseCase: deleteUseCase)

        let replaced = await sut.replaceFuelingPlan(
            oldPlan: FuelingResult.buildMock(name: "Old", itemId: "old"),
            updatedPlan: FuelingResult.buildMock(name: "New", itemId: "new")
        )

        #expect(!replaced)
        #expect(await deleteUseCase.deletedPlans.count == 1)
        #expect(sut.errorMessage == Localizables.Errors.fuelingPlanSaveFailed)
    }
}

// MARK: - Mocks

private actor SaveFuelingPlanUseCaseMock: SaveFuelingPlanUseCase {
    private(set) var savedCalls: [(plan: FuelingResult, planName: String)] = []
    private let executeError: Error?

    init(executeError: Error? = nil) {
        self.executeError = executeError
    }

    func execute(plan: FuelingResult, planName: String) async throws {
        if let executeError {
            throw executeError
        }
        savedCalls.append((plan, planName))
    }
}

private actor DeleteStoredFuelingResultUseCaseMock: DeleteStoredFuelingResultUseCase {
    private(set) var deletedPlans: [FuelingResult] = []
    private let executeError: Error?

    init(executeError: Error? = nil) {
        self.executeError = executeError
    }

    func execute(plan: FuelingResult) async throws {
        if let executeError {
            throw executeError
        }
        deletedPlans.append(plan)
    }
}
