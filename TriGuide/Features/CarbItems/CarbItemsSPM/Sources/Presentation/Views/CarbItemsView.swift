//
// TriGuide 2025
//

import SwiftUI
import Localization

public struct CarbItemsView: View {
    @ObservedObject var viewModel: CarbItemsViewModel
    @State private var searchText = ""
    @State private var filteredItems: [CarbItem] = []

    public init(viewModel: CarbItemsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(filteredItems, id: \.self) { carbItem in
                    CarbItemView(item: carbItem)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .refreshable {
                await viewModel.loadCarbItems(forceRefresh: true)
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .navigationTitle(Localizables.CarbItems.title)
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if viewModel.state == .loading {
                    ProgressView()
                }
            }
            .onChange(of: viewModel.carbItems) { _, newItems in
                filteredItems = searchText.isEmpty
                    ? newItems
                    : viewModel.filterCarbItems(by: searchText)
            }
            .onChange(of: searchText) { _, newSearchText in
                filteredItems = newSearchText.isEmpty
                    ? viewModel.carbItems
                    : viewModel.filterCarbItems(by: newSearchText)
            }
            .task {
                await viewModel.loadCarbItems()
            }
        }
        .background(Color(.systemGroupedBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CarbItemsView(
        viewModel: CarbItemsViewModel(
            loadCarbItemsUseCase: LoadCarbItemsUseCaseDefault(
                repository: CarbItemsRepositoryDefault(
                    remoteDataSource: CarbItemsDataSourceDefault(),
                    localDataSource: LocalCarbItemsDataSourceDefault()
                )
            ),
            searchCarbItemsUseCase: SearchCarbItemsUseCaseDefault()
        )
    )
}
