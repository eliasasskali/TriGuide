//
// TriGuide 2025
//

import SwiftUI
import Localization

public struct CarbItemsView: View {
    @ObservedObject var viewModel: CarbItemsViewModel

    private enum Route: Hashable {
        case form(existingItem: CarbItem?)
    }

    @State private var path: [Route] = []

    @State private var searchText = ""
    @State private var filteredItems: [CarbItem] = []
    @State private var filteredUserItems: [CarbItem] = []

    public init(viewModel: CarbItemsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $path) {
            List {
                if !filteredUserItems.isEmpty {
                    userItemsSection
                }

                if !filteredItems.isEmpty {
                    itemsSection
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .refreshable {
                await viewModel.loadCarbItems(forceRefresh: true)
                await viewModel.loadUserCarbItems(forceRefresh: true)
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .navigationTitle(Localizables.CarbItems.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(.form(existingItem: nil))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
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
            .onChange(of: viewModel.userCarbItems) { _, newUserItems in
                filteredUserItems = searchText.isEmpty
                    ? newUserItems
                    : viewModel.filterUserCarbItems(by: searchText)
            }
            .onChange(of: searchText) { _, newSearchText in
                updateFilteredItems(with: newSearchText)
            }
            .task {
                await viewModel.loadCarbItems()
                await viewModel.loadUserCarbItems()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .form(let existing):
                    buildFormView(for: existing)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension CarbItemsView {
    var userItemsSection: some View {
        Section(header: Text(Localizables.CarbItems.userItemsSectionTitle)) {
            ForEach(filteredUserItems, id: \.self) { carbItem in
                CarbItemView(item: carbItem)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteUserCarbItem(item: carbItem)
                            }
                        } label: {
                            Label(Localizables.Common.delete, systemImage: "trash")
                        }

                        Button {
                            path.append(.form(existingItem: carbItem))
                        } label: {
                            Label(Localizables.Common.edit, systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listSectionSeparator(.hidden)
    }

    var itemsSection: some View {
        Section(header: Text(Localizables.CarbItems.allItemsSectionTitle)) {
            ForEach(filteredItems, id: \.self) { carbItem in
                CarbItemView(item: carbItem)
                    .listRowSeparator(.hidden)
            }
        }
        .listSectionSeparator(.hidden)
    }

    @ViewBuilder
    func buildFormView(for existingItem: CarbItem? = nil) -> some View {
        let formViewModel = CarbItemFormViewModel(
            existingItem: existingItem,
            saveAction: { savedItem in
                Task {
                    if let existingItem {
                        await viewModel.editUserCarbItem(newItem: savedItem, oldItem: existingItem)
                    } else {
                        await viewModel.addUserCarbItem(item: savedItem)
                    }
                }
            }
        )

        CarbItemFormView(viewModel: formViewModel)
    }

    func updateFilteredItems(with searchText: String) {
        filteredItems = searchText.isEmpty
            ? viewModel.carbItems
            : viewModel.filterCarbItems(by: searchText)

        filteredUserItems = searchText.isEmpty
            ? viewModel.userCarbItems
            : viewModel.filterUserCarbItems(by: searchText)
    }
}

// MARK: - Preview

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    let view: CarbItemsView

    init() {
        let repository = try! CarbItemsRepositoryDefault(
            remoteCarbItemsDataSource: RemoteCarbItemsDataSourceDefault(),
            cachedCarbItemsDataSource: CachedCarbItemsDataSourceDefault(),
            userCarbItemsDataSource: UserCarbItemsDataSourceDefault()
        )

        let viewModel = CarbItemsViewModel(
            loadCarbItemsUseCase: LoadCarbItemsUseCaseDefault(repository: repository),
            loadUserCarbItemsUseCase: LoadUserCarbItemsUseCaseDefault(repository: repository),
            addUserCarbItemUseCase: AddUserCarbItemUseCaseDefault(repository: repository),
            deleteUserCarbItemUseCase: DeleteUserCarbItemUseCaseDefault(repository: repository),
            searchCarbItemsUseCase: SearchCarbItemsUseCaseDefault()
        )

        self.view = CarbItemsView(viewModel: viewModel)
    }

    var body: some View {
        view
    }
}
