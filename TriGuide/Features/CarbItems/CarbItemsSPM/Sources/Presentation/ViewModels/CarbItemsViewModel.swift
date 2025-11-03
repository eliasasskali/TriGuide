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
    let addUserCarbItemUseCase: AddUserCarbItemUseCase
    let deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase
    let searchCarbItemsUseCase: SearchCarbItemsUseCase

    init(
        loadCarbItemsUseCase: LoadCarbItemsUseCase,
        addUserCarbItemUseCase: AddUserCarbItemUseCase,
        deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase,
        searchCarbItemsUseCase: SearchCarbItemsUseCase,
    ) {
        self.loadCarbItemsUseCase = loadCarbItemsUseCase
        self.addUserCarbItemUseCase = addUserCarbItemUseCase
        self.deleteUserCarbItemUseCase = deleteUserCarbItemUseCase
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

    func addUserCarbItem(item: CarbItem) async {
        state = .loading
        do {
            try await addUserCarbItemUseCase.execute(item: item)
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }

    func deleteUserCarbItem(item: CarbItem) async {
        do {
            try await deleteUserCarbItemUseCase.execute(item: item)
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }
}

private extension CarbItemsViewModel {
    func handle(_ error: Error) {
        errorMessage = "TODO: handle error"
    }
}

