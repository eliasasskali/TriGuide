//
// TriGuide 2025
//

import SwiftUI

public struct CarbItemsView: View {
    @ObservedObject var viewModel: CarbItemsViewModel

    public init(viewModel: CarbItemsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: .zero) {
            List {
                ForEach(viewModel.carbItems, id: \.self) { carbItem in
                    Text(carbItem.name)
                }
            }
            .refreshable {
                await viewModel.loadCarbItems(forceRefresh: true)
            }
            .overlay {
                if viewModel.state == .loading {
                    ProgressView()
                }
            }
        }
        .task {
            await viewModel.loadCarbItems()
        }
    }
}

#Preview {
    CarbItemsView(
        viewModel: CarbItemsViewModel(
            loadCarbItemsUseCase: LoadCarbItemsUseCase(
                repository: CarbItemsRepositoryDefault(
                    remoteDataSource: CarbItemsDataSourceDefault(),
                    localDataSource: LocalCarbItemsDataSourceDefault()
                )
            )
        )
    )
}
