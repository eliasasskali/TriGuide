//
// TriGuide 2026
//

@testable import RaceNutritionSPM
import Testing
import TriGuideDomain
import struct TriGuideDomain.FuelingResult

@Suite
struct NutritionPlansUseCasesTests {}

extension NutritionPlansUseCasesTests {
    @Test("SaveFuelingPlanUseCase delegates to repository add")
    func saveFuelingPlanUseCaseDefault_whenExecute_thenDelegatesToRepositoryAdd() async throws {
        let repository = UseCaseNutritionPlansRepositoryMock()
        let sut = SaveFuelingPlanUseCaseDefault(repository: repository)
        let plan = TriGuideDomain.FuelingResult.buildMock(itemId: "save")

        try await sut.execute(plan: plan, planName: "My Plan")

        let addedPlans = await repository.addedPlans
        #expect(await repository.addCallCount == 1)
        #expect(addedPlans.count == 1)
        #expect(addedPlans[0].plan == plan)
        #expect(addedPlans[0].name == "My Plan")
    }

    @Test("FetchStoredFuelingResultsUseCase delegates to repository fetch")
    func fetchStoredFuelingResultsUseCaseDefault_whenExecute_thenDelegatesToRepositoryFetch() async throws {
        let plan = TriGuideDomain.FuelingResult.buildMock(itemId: "fetch")
        let repository = UseCaseNutritionPlansRepositoryMock(fetchResult: [plan])
        let sut = FetchStoredFuelingResultsUseCaseDefault(repository: repository)

        let plans = try await sut.execute()

        #expect(await repository.fetchCallCount == 1)
        #expect(plans == [plan])
    }

    @Test("DeleteStoredFuelingResultUseCase delegates to repository delete")
    func deleteStoredFuelingResultUseCaseDefault_whenExecute_thenDelegatesToRepositoryDelete() async throws {
        let plan = TriGuideDomain.FuelingResult.buildMock(itemId: "delete")
        let repository = UseCaseNutritionPlansRepositoryMock()
        let sut = DeleteStoredFuelingResultUseCaseDefault(repository: repository)

        try await sut.execute(plan: plan)

        #expect(await repository.deleteCallCount == 1)
        #expect(await repository.deletedPlans == [plan])
    }
}

private actor UseCaseNutritionPlansRepositoryMock: NutritionPlansRepository {
    enum MockError: Error {
        case fetchFailed
        case addFailed
        case deleteFailed
    }

    private(set) var fetchCallCount = 0
    private(set) var addCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var addedPlans: [(plan: TriGuideDomain.FuelingResult, name: String)] = []
    private(set) var deletedPlans: [TriGuideDomain.FuelingResult] = []

    var fetchResult: [TriGuideDomain.FuelingResult]
    var shouldThrowOnFetch: Bool
    var shouldThrowOnAdd: Bool
    var shouldThrowOnDelete: Bool

    init(
        fetchResult: [TriGuideDomain.FuelingResult] = [],
        shouldThrowOnFetch: Bool = false,
        shouldThrowOnAdd: Bool = false,
        shouldThrowOnDelete: Bool = false
    ) {
        self.fetchResult = fetchResult
        self.shouldThrowOnFetch = shouldThrowOnFetch
        self.shouldThrowOnAdd = shouldThrowOnAdd
        self.shouldThrowOnDelete = shouldThrowOnDelete
    }

    func fetchNutritionPlans() async throws -> [TriGuideDomain.FuelingResult] {
        fetchCallCount += 1
        if shouldThrowOnFetch {
            throw MockError.fetchFailed
        }
        return fetchResult
    }

    func addNutritionPlan(_ plan: TriGuideDomain.FuelingResult, name: String) async throws {
        addCallCount += 1
        if shouldThrowOnAdd {
            throw MockError.addFailed
        }
        addedPlans.append((plan: plan, name: name))
    }

    func deleteNutritionPlan(_ plan: TriGuideDomain.FuelingResult) async throws {
        deleteCallCount += 1
        if shouldThrowOnDelete {
            throw MockError.deleteFailed
        }
        deletedPlans.append(plan)
    }
}
