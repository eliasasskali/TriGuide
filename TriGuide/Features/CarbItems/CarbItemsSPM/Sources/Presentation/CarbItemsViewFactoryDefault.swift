//
// TriGuide 2025
//

import Foundation
import FormKit

public final class CarbItemsViewFactoryDefault: CarbItemsViewFactory {
    public struct Dependencies {
        let remoteCarbItemsDataSource: RemoteCarbItemsDataSource
        let localCarbItemsDataSource: CachedCarbItemsDataSource
        let userCarbItemsDataSource: UserCarbItemsDataSource
        let carbItemsRepository: CarbItemsRepository
        let loadCarbItemsUseCase: LoadCarbItemsUseCase
        let addUserCarbItemUseCase: AddUserCarbItemUseCase
        let deleteUserCarbItemUseCase: DeleteUserCarbItemUseCase
        let searchCarbItemsUseCase: SearchCarbItemsUseCase

        public init(
            remoteCarbItemsDataSource: RemoteCarbItemsDataSource? = nil,
            cachedCarbItemsDataSource: CachedCarbItemsDataSource? = nil,
            userCarbItemsDataSource: UserCarbItemsDataSource? = nil,
            carbItemsRepository: CarbItemsRepository? = nil,
            loadCarbItemsUseCase: LoadCarbItemsUseCase? = nil,
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
            self.addUserCarbItemUseCase = addUserCarbItemUseCase ?? AddUserCarbItemUseCaseDefault(repository: repository)
            self.deleteUserCarbItemUseCase = deleteUserCarbItemUseCase ?? DeleteUserCarbItemUseCaseDefault(repository: repository)
            self.searchCarbItemsUseCase = searchCarbItemsUseCase ?? SearchCarbItemsUseCaseDefault()
        }
    }

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    @MainActor public func buildCarbItemsView() -> CarbItemsView {
        let viewModel = CarbItemsViewModel(
            loadCarbItemsUseCase: dependencies.loadCarbItemsUseCase,
            addUserCarbItemUseCase: dependencies.addUserCarbItemUseCase,
            deleteUserCarbItemUseCase: dependencies.deleteUserCarbItemUseCase,
            searchCarbItemsUseCase: dependencies.searchCarbItemsUseCase
        )

        return CarbItemsView(viewModel: viewModel)
    }

    @MainActor public func buildCarbItemFormView(
        sections: [FormSection]?,
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

// MARK: - Convenience initializer without parameters

public extension CarbItemsViewFactoryDefault {
    @MainActor
    static func makeViewOrNil() -> CarbItemsView? {
        do {
            return try CarbItemsViewFactoryDefault(dependencies: .init())
                .buildCarbItemsView()
        } catch {
            return nil
        }
    }
}
