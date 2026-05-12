//
// TriGuide 2025
//

import Foundation
import NavigationKit
import SwiftUI
import TriGuideDomain

public class CarbItemsCoordinator: BaseCoordinator<CarbItemsCoordinator.Route, Never, CarbItemsView> {
    // MARK: - Route

    public enum Route: Hashable {
        case form(existingItem: CarbItem?)
    }

    // MARK: - Dependencies

    let factory: CarbItemsViewFactory
    public let analyticsService: CarbItemsAnalyticsService
    public let onCompleteSelection: (([CarbItemSelection]) -> Void)?
    public var calculationId: String?

    @Published public var viewModel: CarbItemsViewModel

    // MARK: - Initializer

    public init(
        factory: CarbItemsViewFactory,
        analyticsService: CarbItemsAnalyticsService = CarbItemsAnalyticsServiceNoOp(),
        onCompleteSelection: (([CarbItemSelection]) -> Void)? = nil
    ) {
        self.factory = factory
        self.analyticsService = analyticsService
        self.onCompleteSelection = onCompleteSelection
        viewModel = factory.buildCarbItemsViewModel()
        super.init()
    }

    // MARK: - BaseCoordinator

    override public func start() -> CarbItemsView {
        factory.buildCarbItemsView(
            viewModel: viewModel,
            coordinator: self
        )
    }
}

// MARK: - Navigation

public extension CarbItemsCoordinator {
    func pushCarbItemForm(for existingItem: CarbItem? = nil) {
        if existingItem != nil {
            analyticsService.trackEditItemScreenView()
        } else {
            analyticsService.trackNewItemFormScreenView()
        }
        push(.form(existingItem: existingItem))
    }

    @ViewBuilder
    func buildFormView(for existingItem: CarbItem? = nil) -> CarbItemFormView {
        let saveAction: (CarbItem) -> Void = { [weak self] savedItem in
            Task { @MainActor in
                guard let self = self else { return }
                if let old = existingItem {
                    self.analyticsService.trackEditCarbItem(item: savedItem)
                    await self.viewModel.editUserCarbItem(newItem: savedItem, oldItem: old)
                } else {
                    self.analyticsService.trackCreateCarbItem(item: savedItem)
                    await self.viewModel.addUserCarbItem(item: savedItem)
                }
            }
        }

        factory.buildCarbItemFormView(
            sections: CarbItemFormViewModel.defaultSections,
            existingItem: existingItem,
            saveAction: saveAction
        )
    }
}
