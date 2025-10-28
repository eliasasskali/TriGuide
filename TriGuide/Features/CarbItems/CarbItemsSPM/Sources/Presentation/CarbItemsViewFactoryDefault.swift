//
// TriGuide 2025
//

import Foundation

public final class CarbItemsViewFactoryDefault: CarbItemsViewFactory {
    public struct Dependencies {
        let carbItemsDataSource: CarbItemsDataSource
        let carbItemsRepository: CarbItemsRepository
        let loadCarbItemsUseCase: LoadCarbItemsUseCase

        public init(
            carbItemsDataSource: CarbItemsDataSource? = nil,
            carbItemsRepository: CarbItemsRepository? = nil,
            loadCarbItemsUseCase: LoadCarbItemsUseCase? = nil
        ) {
            let dataSource = carbItemsDataSource ?? CarbItemsDataSourceDefault()
            let repository = carbItemsRepository ?? CarbItemsRepositoryDefault(dataSource: dataSource)

            self.carbItemsDataSource = dataSource
            self.carbItemsRepository = repository
            self.loadCarbItemsUseCase = loadCarbItemsUseCase ?? LoadCarbItemsUseCase(repository: repository)
        }
    }

    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    @MainActor public func buildCarbItemsView() -> CarbItemsView {
        let viewModel = CarbItemsViewModel(
            loadCarbItemsUseCase: dependencies.loadCarbItemsUseCase
        )

        return CarbItemsView(viewModel: viewModel)
    }
}

// MARK: - Convenience initializer without parameters

public extension CarbItemsViewFactoryDefault {
    @MainActor
    static func makeView() -> CarbItemsView {
        CarbItemsViewFactoryDefault(dependencies: .init())
            .buildCarbItemsView()
    }
}
