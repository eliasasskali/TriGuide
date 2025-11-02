//
// TriGuide 2025
//

import Foundation

public final class CarbItemsViewFactoryDefault: CarbItemsViewFactory {
    public struct Dependencies {
        let remoteCarbItemsDataSource: RemoteCarbItemsDataSource
        let localCarbItemsDataSource: CachedCarbItemsDataSource
        let userCarbItemsDataSource: UserCarbItemsDataSource
        let carbItemsRepository: CarbItemsRepository
        let loadCarbItemsUseCase: LoadCarbItemsUseCase
        let searchCarbItemsUseCase: SearchCarbItemsUseCase

        public init(
            remoteCarbItemsDataSource: RemoteCarbItemsDataSource? = nil,
            cachedCarbItemsDataSource: CachedCarbItemsDataSource? = nil,
            userCarbItemsDataSource: UserCarbItemsDataSource? = nil,
            carbItemsRepository: CarbItemsRepository? = nil,
            loadCarbItemsUseCase: LoadCarbItemsUseCase? = nil,
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
            searchCarbItemsUseCase: dependencies.searchCarbItemsUseCase
        )

        return CarbItemsView(viewModel: viewModel)
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
