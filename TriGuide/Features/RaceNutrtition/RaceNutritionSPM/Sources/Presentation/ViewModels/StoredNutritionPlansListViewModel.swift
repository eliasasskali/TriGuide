//
// TriGuide 2026
//

import Combine
import Foundation
import Localization
import TriGuideDomain

@MainActor
public class StoredNutritionPlansListViewModel: ObservableObject {
    // MARK: - Dependencies

    private let fetchStoredFuelingResultsUseCase: FetchStoredFuelingResultsUseCase
    private let deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCase

    // MARK: - Properties

    @Published var plans: [FuelingResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Initializer

    public init(
        fetchStoredFuelingResultsUseCase: FetchStoredFuelingResultsUseCase,
        deleteStoredFuelingResultUseCase: DeleteStoredFuelingResultUseCase
    ) {
        self.fetchStoredFuelingResultsUseCase = fetchStoredFuelingResultsUseCase
        self.deleteStoredFuelingResultUseCase = deleteStoredFuelingResultUseCase
    }

    // MARK: - Methods

    func fetchStoredPlans() async {
        isLoading = true
        defer { isLoading = false }

        do {
            plans = try await fetchStoredFuelingResultsUseCase.execute()
        } catch {
            errorMessage = Localizables.Errors.generic
        }
    }

    func deletePlan(at offsets: IndexSet) async {
        let plansToDelete = offsets.compactMap { index in
            plans.indices.contains(index) ? plans[index] : nil
        }

        do {
            for plan in plansToDelete {
                try await deleteStoredFuelingResultUseCase.execute(plan: plan)
            }
            plans.remove(atOffsets: offsets)
        } catch {
            errorMessage = Localizables.Errors.fuelingPlanDeleteFailed
        }
    }
}
