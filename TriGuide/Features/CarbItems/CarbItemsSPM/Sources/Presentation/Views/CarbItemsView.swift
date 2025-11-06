//
// TriGuide 2025
//

import SwiftUI
import Localization

public struct CarbItemsView: View {
    @ObservedObject private var viewModel: CarbItemsViewModel
    @ObservedObject private var coordinator: CarbItemsCoordinator

    @State private var searchText = ""
    @State private var filteredItems: [CarbItem] = []
    @State private var filteredUserItems: [CarbItem] = []

    public init(
        viewModel: CarbItemsViewModel,
        coordinator: CarbItemsCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        NavigationStack(path: coordinator.pathBinding) {
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
                        coordinator.presentCarbItemForm()
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
            .navigationDestination(for: CarbItemsCoordinator.Route.self) { route in
                switch route {
                case .form(let existing):
                    coordinator.buildFormView(for: existing)
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
                            coordinator.presentCarbItemForm(for: carbItem)
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
        let coordinator = CarbItemsCoordinator(factory: CarbItemsViewFactoryDefault(dependencies: try! .init()))

        self.view = CarbItemsView(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }

    var body: some View {
        view
    }
}
