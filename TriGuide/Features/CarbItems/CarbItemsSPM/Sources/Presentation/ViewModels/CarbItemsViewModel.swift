//
// TriGuide 2025
//

import Foundation

@MainActor
public class CarbItemsViewModel: ObservableObject {
    enum ViewState: Equatable {
        case unloaded
        case loading
        case loaded
    }

    @Published var state: ViewState = .unloaded
    @Published var errorMessage: String? = nil
    @Published var carbItems: [CarbItem] = []

    let loadCarbItemsUseCase: LoadCarbItemsUseCase
    let searchCarbItemsUseCase: SearchCarbItemsUseCase

    init(
        loadCarbItemsUseCase: LoadCarbItemsUseCase,
        searchCarbItemsUseCase: SearchCarbItemsUseCase
    ) {
        self.loadCarbItemsUseCase = loadCarbItemsUseCase
        self.searchCarbItemsUseCase = searchCarbItemsUseCase
    }
}

extension CarbItemsViewModel {
    func loadCarbItems(forceRefresh: Bool = false) async {
        state = .loading
        do {
            let useCase = loadCarbItemsUseCase
            carbItems = try await useCase.execute(forceRefresh: forceRefresh)
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }

    func filterCarbItems(by searchText: String) -> [CarbItem] {
        searchCarbItemsUseCase.execute(carbItems: carbItems, searchText: searchText)
    }
}

private extension CarbItemsViewModel {
    func handle(_ error: Error) {
        errorMessage = "TODO: handle error"
    }
}

