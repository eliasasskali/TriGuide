//
// TriGuide 2025
//

import Foundation
import Localization
import TriGuideDomain

@MainActor
public class CarbItemsViewModel: ObservableObject {
    // MARK: - State

    enum ViewState: Equatable {
        case unloaded
        case loading
        case loaded
    }

    // MARK: - Dependencies

    let loadCarbItemsUseCase: LoadCarbItemsUseCase
    let loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase
    let addUserCarbItemUseCase: AddUserCarbItemUseCase
    let deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase
    let toggleFavoriteCarbItemUseCase: ToggleFavoriteCarbItemUseCase
    let searchCarbItemsUseCase: SearchCarbItemsUseCase

    // MARK: - Properties

    @Published var state: ViewState = .unloaded
    @Published var errorMessage: String? = nil
    @Published var carbItems: [CarbItem] = []
    @Published var userCarbItems: [CarbItem] = []
    @Published var selectedCarbItems: [CarbItemSelection] = []
    @Published public var totalCarbGrams: Double?

    // MARK: - Computed Properties

    var selectedItemsCarbsSum: Double {
        selectedCarbItems.reduce(0.0) {
            $0 + $1.item.gramsOfCarbs * Double($1.quantity)
        }
    }

    var selectedItemsProgress: Double {
        guard let totalCarbGrams, totalCarbGrams > 0 else {
            return 0.0
        }
        return selectedItemsCarbsSum / totalCarbGrams
    }

    // MARK: - Initializer

    init(
        loadCarbItemsUseCase: LoadCarbItemsUseCase,
        loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase,
        addUserCarbItemUseCase: AddUserCarbItemUseCase,
        deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase,
        toggleFavoriteCarbItemUseCase: ToggleFavoriteCarbItemUseCase,
        searchCarbItemsUseCase: SearchCarbItemsUseCase,
        totalCarbGrams: Double? = nil
    ) {
        self.loadCarbItemsUseCase = loadCarbItemsUseCase
        self.loadUserCarbItemsUseCase = loadUserCarbItemsUseCase
        self.addUserCarbItemUseCase = addUserCarbItemUseCase
        self.deleteUserCarbItemUseCase = deleteUserCarbItemUseCase
        self.toggleFavoriteCarbItemUseCase = toggleFavoriteCarbItemUseCase
        self.searchCarbItemsUseCase = searchCarbItemsUseCase
        self.totalCarbGrams = totalCarbGrams
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
            syncSelectedItemsWithUpdatedUserItems()
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
            syncSelectedItemsWithUpdatedUserItems()
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
            syncSelectedItemsWithUpdatedUserItems()
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
            syncSelectedItemsWithUpdatedUserItems()
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }
}

// MARK: - Selection methods

public extension CarbItemsViewModel {
    func onSelectCarbItem(_ selection: CarbItemSelection) {
        if selection.quantity <= 0 {
            selectedCarbItems.removeAll(where: { $0.item.id == selection.item.id })
            return
        }

        if let index = selectedCarbItems.firstIndex(where: { $0.item.id == selection.item.id }) {
            selectedCarbItems[index] = selection
        } else {
            selectedCarbItems.append(selection)
        }
    }

    func syncSelectedItemsWithUpdatedUserItems() {
        let allItems = carbItems + userCarbItems
        selectedCarbItems = selectedCarbItems.compactMap { selection in
            guard let updatedItem = allItems.first(where: { $0.id == selection.item.id }) else {
                return nil
            }
            return CarbItemSelection(item: updatedItem, quantity: selection.quantity)
        }
    }
}

private extension CarbItemsViewModel {
    func handle(_ error: Error) {
        guard let repositoryError =
            error as? CarbItemsRepositoryDefault.RepositoryError
        else {
            errorMessage = Localizables.Errors.generic
            return
        }

        switch repositoryError {
        case .duplicateUserItem:
            errorMessage = Localizables.Errors.carbItemsDuplicateItem
        case .remoteAndCacheFailed(remoteError: _, cacheError: _):
            errorMessage = Localizables.Errors.carbItemsLoadingFailed
        }
    }

    func sortCarbItemsByFavourites(_ items: [CarbItem]) -> [CarbItem] {
        items.sorted { lhs, rhs in
            if lhs.isFavorite == rhs.isFavorite {
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            } else {
                lhs.isFavorite && !rhs.isFavorite
            }
        }
    }
}
