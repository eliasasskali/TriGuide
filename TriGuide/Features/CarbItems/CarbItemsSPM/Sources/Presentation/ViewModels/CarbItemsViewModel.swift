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
    @Published var userCarbItems: [CarbItem] = []

    var favoriteCarbITems: [CarbItem] {
        carbItems.filter(\.isFavorite)
    }

    let loadCarbItemsUseCase: LoadCarbItemsUseCase
    let loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase
    let addUserCarbItemUseCase: AddUserCarbItemUseCase
    let deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase
    let toggleFavoriteCarbItemUseCase: ToggleFavoriteCarbItemUseCase
    let searchCarbItemsUseCase: SearchCarbItemsUseCase

    init(
        loadCarbItemsUseCase: LoadCarbItemsUseCase,
        loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase,
        addUserCarbItemUseCase: AddUserCarbItemUseCase,
        deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase,
        toggleFavoriteCarbItemUseCase: ToggleFavoriteCarbItemUseCase,
        searchCarbItemsUseCase: SearchCarbItemsUseCase
    ) {
        self.loadCarbItemsUseCase = loadCarbItemsUseCase
        self.loadUserCarbItemsUseCase = loadUserCarbItemsUseCase
        self.addUserCarbItemUseCase = addUserCarbItemUseCase
        self.deleteUserCarbItemUseCase = deleteUserCarbItemUseCase
        self.toggleFavoriteCarbItemUseCase = toggleFavoriteCarbItemUseCase
        self.searchCarbItemsUseCase = searchCarbItemsUseCase
    }
}

// MARK: - Carb Items methods

extension CarbItemsViewModel {
    func loadCarbItems(forceRefresh: Bool = false) async {
        state = .loading
        do {
            let useCase = loadCarbItemsUseCase
            let items = try await useCase.execute(forceRefresh: forceRefresh)
            carbItems = sortCarbItemsByFavourites(items)
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }

    func filterCarbItems(by searchText: String) -> [CarbItem] {
        searchCarbItemsUseCase.execute(carbItems: carbItems, searchText: searchText)
    }

    // MARK: - Favorite Carb Items methods

    func toggleFavorite(for item: CarbItem) async {
        await toggleFavoriteCarbItemUseCase.execute(id: item.id)
        await loadCarbItems()
    }
}

// MARK: - User Carb Items methods

extension CarbItemsViewModel {
    func loadUserCarbItems(forceRefresh: Bool = false) async {
        state = .loading
        do {
            let useCase = loadUserCarbItemsUseCase
            userCarbItems = try await useCase.execute(forceRefresh: forceRefresh)
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }

    func filterUserCarbItems(by searchText: String) -> [CarbItem] {
        searchCarbItemsUseCase.execute(carbItems: userCarbItems, searchText: searchText)
    }

    func addUserCarbItem(item: CarbItem) async {
        state = .loading
        do {
            try await addUserCarbItemUseCase.execute(item: item)
            await loadUserCarbItems()
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }

    func deleteUserCarbItem(item: CarbItem) async {
        do {
            try await deleteUserCarbItemUseCase.execute(item: item)
            await loadUserCarbItems()
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }

    func editUserCarbItem(newItem: CarbItem, oldItem: CarbItem) async {
        state = .loading
        do {
            try await deleteUserCarbItemUseCase.execute(item: oldItem)
            try await addUserCarbItemUseCase.execute(item: newItem)
            await loadUserCarbItems(forceRefresh: true)
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

    private func sortCarbItemsByFavourites(_ items: [CarbItem]) -> [CarbItem] {
        items.sorted { lhs, rhs in
            if lhs.isFavorite == rhs.isFavorite {
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            } else {
                lhs.isFavorite && !rhs.isFavorite
            }
        }
    }
}

