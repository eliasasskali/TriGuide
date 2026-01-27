//
// TriGuide 2025
//

import FormKit
import Foundation
import TriGuideDomain

public final class CarbItemsViewFactoryDefault {
    public struct Dependencies {
        let loadCarbItemsUseCase: LoadCarbItemsUseCase
        let loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase
        let addUserCarbItemUseCase: AddUserCarbItemUseCase
        let deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase
        let toggleFavoriteCarbItemUseCase: ToggleFavoriteCarbItemUseCase
        let searchCarbItemsUseCase: SearchCarbItemsUseCase

        let totalCarbGrams: Double?

        public init(
            remoteCarbItemsDataSource: RemoteCarbItemsDataSource? = nil,
            cachedCarbItemsDataSource: CachedCarbItemsDataSource? = nil,
            favoriteCarbItemsDataSource: FavoriteCarbItemsDataSource? = nil,
            userCarbItemsDataSource: UserCarbItemsDataSource? = nil,
            carbItemsRepository: CarbItemsRepository? = nil,
            loadCarbItemsUseCase: LoadCarbItemsUseCase? = nil,
            loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase? = nil,
            addUserCarbItemUseCase: AddUserCarbItemUseCase? = nil,
            deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase? = nil,
            toggleFavoriteCarbItemUseCase: ToggleFavoriteCarbItemUseCase? = nil,
            searchCarbItemsUseCase: SearchCarbItemsUseCase? = nil,
            totalCarbGrams: Double? = nil
        ) throws {
            let remoteItemsDataSource = remoteCarbItemsDataSource ?? RemoteCarbItemsDataSourceDefault()
            let cachedItemsDataSource = try cachedCarbItemsDataSource ?? CachedCarbItemsDataSourceDefault()
            let userItemsDataSource = try userCarbItemsDataSource ?? UserCarbItemsDataSourceDefault()
            let favoriteCarbItemsDataSource = favoriteCarbItemsDataSource ?? FavoriteCarbItemsDataSourceDefault()
            let repository = carbItemsRepository ?? CarbItemsRepositoryDefault(
                remoteCarbItemsDataSource: remoteItemsDataSource,
                cachedCarbItemsDataSource: cachedItemsDataSource,
                favoriteCarbItemsDataSource: favoriteCarbItemsDataSource,
                userCarbItemsDataSource: userItemsDataSource
            )

            self.loadCarbItemsUseCase = loadCarbItemsUseCase ?? LoadCarbItemsUseCaseDefault(repository: repository)
            self.loadUserCarbItemsUseCase = loadUserCarbItemsUseCase ?? LoadUserCarbItemsUseCaseDefault(repository: repository)
            self.addUserCarbItemUseCase = addUserCarbItemUseCase ?? AddUserCarbItemUseCaseDefault(repository: repository)
            self.deleteUserCarbItemUseCase = deleteUserCarbItemUseCase ?? DeleteUserCarbItemUseCaseDefault(repository: repository)
            self.toggleFavoriteCarbItemUseCase = toggleFavoriteCarbItemUseCase ?? ToggleFavoriteCarbItemUseCaseDefault(repository: repository)
            self.searchCarbItemsUseCase = searchCarbItemsUseCase ?? SearchCarbItemsUseCaseDefault()

            self.totalCarbGrams = totalCarbGrams
        }
    }

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - CarbItemsViewFactory

extension CarbItemsViewFactoryDefault: CarbItemsViewFactory {
    @MainActor public func buildCarbItemsView(
        viewModel: CarbItemsViewModel,
        coordinator: CarbItemsCoordinator
    ) -> CarbItemsView {
        CarbItemsView(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }

    @MainActor public func buildCarbItemsViewModel() -> CarbItemsViewModel {
        CarbItemsViewModel(
            loadCarbItemsUseCase: dependencies.loadCarbItemsUseCase,
            loadUserCarbItemsUseCase: dependencies.loadUserCarbItemsUseCase,
            addUserCarbItemUseCase: dependencies.addUserCarbItemUseCase,
            deleteUserCarbItemUseCase: dependencies.deleteUserCarbItemUseCase,
            toggleFavoriteCarbItemUseCase: dependencies.toggleFavoriteCarbItemUseCase,
            searchCarbItemsUseCase: dependencies.searchCarbItemsUseCase,
            totalCarbGrams: dependencies.totalCarbGrams
        )
    }

    @MainActor public func buildCarbItemFormView(
        sections: [FormSection]? = nil,
        existingItem: CarbItem?,
        saveAction: @escaping (CarbItem) -> Void
    ) -> CarbItemFormView {
        CarbItemFormView(
            viewModel: CarbItemFormViewModel(
                sections: sections ?? CarbItemFormViewModel.defaultSections,
                existingItem: existingItem,
                saveAction: saveAction
            )
        )
    }
}
