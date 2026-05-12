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
        deleteUseCase: DeleteStoredFuelingResultUseCase = DeleteStoredFuelingResultUseCaseMock(),
        replaceUseCase: ReplaceFuelingPlanUseCase = ReplaceFuelingPlanUseCaseMock()
    ) -> RaceNutritionResultViewModel {
        RaceNutritionResultViewModel(
            saveFuelingPlanUseCase: saveUseCase,
            deleteStoredFuelingResultUseCase: deleteUseCase,
            replaceFuelingPlanUseCase: replaceUseCase
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

    @Test("Replace delegates to replace use case with updated name")
    func raceNutritionResultViewModel_whenReplaceWithUpdatedName_thenDelegatesToReplaceUseCase() async {
        let replaceUseCase = ReplaceFuelingPlanUseCaseMock()
        let sut = givenSut(replaceUseCase: replaceUseCase)

        let oldPlan = FuelingResult.buildMock(name: "Old Name", itemId: "old")
        let updatedPlan = FuelingResult.buildMock(name: "New Name", itemId: "updated")

        let replaced = await sut.replaceFuelingPlan(oldPlan: oldPlan, updatedPlan: updatedPlan)

        #expect(replaced)
        let calls = await replaceUseCase.replacedCalls
        #expect(calls.count == 1)
        #expect(calls[0].oldPlan == oldPlan)
        #expect(calls[0].updatedPlan == updatedPlan)
        #expect(calls[0].planName == "New Name")
    }

    @Test("Replace uses old plan name when updated name is missing")
    func raceNutritionResultViewModel_whenReplaceWithoutUpdatedName_thenUsesOldPlanName() async {
        let replaceUseCase = ReplaceFuelingPlanUseCaseMock()
        let sut = givenSut(replaceUseCase: replaceUseCase)

        let oldPlan = FuelingResult.buildMock(name: "Stored Name", itemId: "old")
        let updatedPlan = FuelingResult.buildMock(name: nil, itemId: "updated")

        let replaced = await sut.replaceFuelingPlan(oldPlan: oldPlan, updatedPlan: updatedPlan)

        #expect(replaced)
        let calls = await replaceUseCase.replacedCalls
        #expect(calls.count == 1)
        #expect(calls[0].planName == "Stored Name")
    }

    @Test("Replace uses unnamed fallback when both names are missing")
    func raceNutritionResultViewModel_whenReplaceWithoutAnyName_thenUsesUnnamedFallback() async {
        let replaceUseCase = ReplaceFuelingPlanUseCaseMock()
        let sut = givenSut(replaceUseCase: replaceUseCase)

        let oldPlan = FuelingResult.buildMock(name: nil, itemId: "old")
        let updatedPlan = FuelingResult.buildMock(name: nil, itemId: "updated")

        let replaced = await sut.replaceFuelingPlan(oldPlan: oldPlan, updatedPlan: updatedPlan)

        #expect(replaced)
        let calls = await replaceUseCase.replacedCalls
        #expect(calls.count == 1)
        #expect(calls[0].planName == Localizables.RaceNutritionResults.storedPlansItemUnnamedPlan)
    }

    @Test("Replace returns false when replace use case fails")
    func raceNutritionResultViewModel_whenReplaceFails_thenReturnsFalse() async {
        let replaceUseCase = ReplaceFuelingPlanUseCaseMock(
            executeError: NutritionPlansRepositoryDefault.RepositoryError.saveFailed
        )
        let sut = givenSut(replaceUseCase: replaceUseCase)

        let replaced = await sut.replaceFuelingPlan(
            oldPlan: FuelingResult.buildMock(name: "Old", itemId: "old"),
            updatedPlan: FuelingResult.buildMock(name: "New", itemId: "new")
        )

        #expect(!replaced)
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

private actor ReplaceFuelingPlanUseCaseMock: ReplaceFuelingPlanUseCase {
    private(set) var replacedCalls: [(oldPlan: FuelingResult, updatedPlan: FuelingResult, planName: String)] = []
    private let executeError: Error?

    init(executeError: Error? = nil) {
        self.executeError = executeError
    }

    func execute(oldPlan: FuelingResult, updatedPlan: FuelingResult, planName: String) async throws {
        if let executeError {
            throw executeError
        }
        replacedCalls.append((oldPlan, updatedPlan, planName))
    }
}
