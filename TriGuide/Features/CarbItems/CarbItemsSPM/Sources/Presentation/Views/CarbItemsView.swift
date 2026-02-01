//
// TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

public struct CarbItemsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Dependencies

    @ObservedObject private var viewModel: CarbItemsViewModel
    @ObservedObject private var coordinator: CarbItemsCoordinator

    // MARK: - Properties

    @State private var searchText = ""
    @State private var quantities: [String: Int] = [:]

    // MARK: - Computed properties

    private var inSelectionMode: Bool {
        viewModel.totalCarbGrams != nil
    }

    private var progressText: String {
        let carbs = viewModel.selectedItemsCarbsSum.formattedAsDecimal(maxFractionDigits: 1)
        let total = (viewModel.totalCarbGrams ?? 0).formattedAsDecimal(maxFractionDigits: 1)
        return "\(carbs) / \(total)\(Localizables.Units.gSymbol)"
    }

    private var filteredItems: [CarbItem] {
        searchText.isEmpty
            ? viewModel.carbItems
            : viewModel.filterCarbItems(by: searchText)
    }

    private var filteredUserItems: [CarbItem] {
        searchText.isEmpty
            ? viewModel.userCarbItems
            : viewModel.filterUserCarbItems(by: searchText)
    }

    // MARK: - Initializer

    public init(
        viewModel: CarbItemsViewModel,
        coordinator: CarbItemsCoordinator
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: coordinator.pathBinding) {
            VStack(spacing: 0) {
                listContent

                if inSelectionMode {
                    Divider()
                    selectedItemsProgressView
                        .padding()
                    ActionButton(
                        Localizables.Common.continueLabel,
                        isLoading: viewModel.state == .loading
                    ) {
                        dismiss()
                        coordinator.onCompleteSelection?(viewModel.selectedCarbItems)
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGroupedBackground))
            .overlay {
                if viewModel.state == .loading { ProgressView() }
            }
            .task { await refreshAll() }
            .errorAlert(message: $viewModel.errorMessage)
            .navigationDestination(for: CarbItemsCoordinator.Route.self) { route in
                switch route {
                case let .form(existing):
                    coordinator.buildFormView(for: existing)
                }
            }
        }
    }
}

private extension CarbItemsView {
    // MARK: - List and Sections

    var listContent: some View {
        List {
            Group {
                if !filteredUserItems.isEmpty {
                    carbItemSection(
                        title: Localizables.CarbItems.userItemsSectionTitle,
                        items: filteredUserItems,
                        allowSwipeActions: true,
                        isUserItem: true
                    )
                }

                if !filteredItems.isEmpty {
                    carbItemSection(
                        title: Localizables.CarbItems.allItemsSectionTitle,
                        items: filteredItems,
                        allowSwipeActions: true,
                        isUserItem: false
                    )
                }
            }
            .listRowBackground(Color.clear)
            .background(Color(.systemGroupedBackground))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText)
        .refreshable {
            await refreshAll()
        }
        .navigationTitle(Localizables.CarbItems.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { addButton }
    }

    func carbItemSection(
        title: String,
        items: [CarbItem],
        allowSwipeActions: Bool,
        isUserItem: Bool
    ) -> some View {
        Section(header: Text(title)) {
            ForEach(items, id: \.self) { carbItem in
                CarbItemView(
                    item: carbItem,
                    quantity: Binding(
                        get: { quantities[carbItem.id, default: 0] },
                        set: { quantities[carbItem.id] = $0 }
                    ),
                    selectable: inSelectionMode
                ) { quantity in
                    let selection = CarbItemSelection(item: carbItem, quantity: Double(quantity))
                    viewModel.onSelectCarbItem(selection)
                }
                .listRowSeparator(.hidden)
                .if(allowSwipeActions) { view in
                    view
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if isUserItem {
                                userItemSwipeActions(for: carbItem)
                            } else {
                                defaultItemSwipeActions(for: carbItem)
                            }
                        }
                }
            }
        }
        .listSectionSeparator(.hidden)
    }

    // MARK: - Swipe Actions

    func userItemSwipeActions(for carbItem: CarbItem) -> some View {
        Group {
            Button(role: .destructive) {
                Task { await viewModel.deleteUserCarbItem(item: carbItem) }
            } label: {
                Label(Localizables.Common.delete, systemImage: "trash")
            }

            Button {
                coordinator.pushCarbItemForm(for: carbItem)
            } label: {
                Label(Localizables.Common.edit, systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    func defaultItemSwipeActions(for carbItem: CarbItem) -> some View {
        Button {
            Task { await viewModel.toggleFavorite(for: carbItem) }
        } label: {
            Label(
                carbItem.isFavorite
                    ? Localizables.Common.removeFromFavorites
                    : Localizables.Common.addToFavorites,
                systemImage: carbItem.isFavorite ? "star.fill" : "star"
            )
        }
        .tint(carbItem.isFavorite ? .red : .yellow)
    }

    // MARK: - Toolbar

    private var addButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                coordinator.pushCarbItemForm()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
        }
    }

    // MARK: - Selected Items Progress

    var selectedItemsProgressView: some View {
        ProgressBarWithLabelView(
            label: Localizables.CarbItems.carbsLabel,
            value: progressText,
            progress: viewModel.selectedItemsProgress
        )
    }

    // MARK: - Helpers

    func refreshAll() async {
        await viewModel.loadCarbItems(forceRefresh: true)
        await viewModel.loadUserCarbItems(forceRefresh: true)
        quantities = Dictionary(
            uniqueKeysWithValues: viewModel.selectedCarbItems.map { ($0.item.id, Int($0.quantity)) }
        )
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
            favoriteCarbItemsDataSource: FavoriteCarbItemsDataSourceDefault(),
            userCarbItemsDataSource: UserCarbItemsDataSourceDefault()
        )

        let viewModel = CarbItemsViewModel(
            loadCarbItemsUseCase: LoadCarbItemsUseCaseDefault(repository: repository),
            loadUserCarbItemsUseCase: LoadUserCarbItemsUseCaseDefault(repository: repository),
            addUserCarbItemUseCase: AddUserCarbItemUseCaseDefault(repository: repository),
            deleteUserCarbItemUseCase: DeleteUserCarbItemUseCaseDefault(repository: repository),
            toggleFavoriteCarbItemUseCase: ToggleFavoriteCarbItemUseCaseDefault(repository: repository),
            searchCarbItemsUseCase: SearchCarbItemsUseCaseDefault()
        )
        let coordinator = CarbItemsCoordinator(factory: CarbItemsViewFactoryDefault(dependencies: try! .init()))

        view = CarbItemsView(
            viewModel: viewModel,
            coordinator: coordinator
        )
    }

    var body: some View {
        view
    }
}
