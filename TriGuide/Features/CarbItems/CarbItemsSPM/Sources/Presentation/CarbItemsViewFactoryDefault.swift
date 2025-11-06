//
// TriGuide 2025
//

import Foundation
import FormKit

public final class CarbItemsViewFactoryDefault {
    public struct Dependencies {
        let remoteCarbItemsDataSource: RemoteCarbItemsDataSource
        let localCarbItemsDataSource: CachedCarbItemsDataSource
        let userCarbItemsDataSource: UserCarbItemsDataSource
        let carbItemsRepository: CarbItemsRepository
        let loadCarbItemsUseCase: LoadCarbItemsUseCase
        let loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase
        let addUserCarbItemUseCase: AddUserCarbItemUseCase
        let deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase
        let searchCarbItemsUseCase: SearchCarbItemsUseCase

        public init(
            remoteCarbItemsDataSource: RemoteCarbItemsDataSource? = nil,
            cachedCarbItemsDataSource: CachedCarbItemsDataSource? = nil,
            userCarbItemsDataSource: UserCarbItemsDataSource? = nil,
            carbItemsRepository: CarbItemsRepository? = nil,
            loadCarbItemsUseCase: LoadCarbItemsUseCase? = nil,
            loadUserCarbItemsUseCase: LoadUserCarbItemsUseCase? = nil,
            addUserCarbItemUseCase: AddUserCarbItemUseCase? = nil,
            deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase? = nil,
            searchCarbItemsUseCase: SearchCarbItemsUseCase? = nil
        ) throws {
            let remoteItemsDataSource = remoteCarbItemsDataSource ?? RemoteCarbItemsDataSourceDefault()
            let cachedItemsDataSource = try cachedCarbItemsDataSource ?? CachedCarbItemsDataSourceDefault()
            let userItemsDataSource = try userCarbItemsDataSource ?? UserCarbItemsDataSourceDefault()
            let repository = carbItemsRepository ?? CarbItemsRepositoryDefault(
                remoteCarbItemsDataSource: remoteItemsDataSource,
                cachedCarbItemsDataSource: cachedItemsDataSource,
                userCarbItemsDataSource: userItemsDataSource
            )

            self.remoteCarbItemsDataSource = remoteItemsDataSource
            self.localCarbItemsDataSource = cachedItemsDataSource
            self.userCarbItemsDataSource = userItemsDataSource
            self.carbItemsRepository = repository
            self.loadCarbItemsUseCase = loadCarbItemsUseCase ?? LoadCarbItemsUseCaseDefault(repository: repository)
            self.loadUserCarbItemsUseCase = loadUserCarbItemsUseCase ?? LoadUserCarbItemsUseCaseDefault(repository: repository)
            self.addUserCarbItemUseCase = addUserCarbItemUseCase ?? AddUserCarbItemUseCaseDefault(repository: repository)
            self.deleteUserCarbItemUseCase = deleteUserCarbItemUseCase ?? DeleteUserCarbItemUseCaseDefault(repository: repository)
            self.searchCarbItemsUseCase = searchCarbItemsUseCase ?? SearchCarbItemsUseCaseDefault()
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
            searchCarbItemsUseCase: dependencies.searchCarbItemsUseCase
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
