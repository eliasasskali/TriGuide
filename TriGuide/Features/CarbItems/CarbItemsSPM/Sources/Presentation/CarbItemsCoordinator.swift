//
// TriGuide 2025
//

import Foundation
import SwiftUI
import NavigationKit
import TriGuideDomain

public class CarbItemsCoordinator: BaseCoordinator<CarbItemsCoordinator.Route, Never, CarbItemsView> {
    public enum Route: Hashable {
        case form(existingItem: CarbItem?)
    }

    let factory: CarbItemsViewFactory
    public let onCompleteSelection: (([CarbItemSelection]) -> Void)?

    @Published public var viewModel: CarbItemsViewModel

    public init(
        factory: CarbItemsViewFactory,
        onCompleteSelection: (([CarbItemSelection]) -> Void)? = nil
    ) {
        self.factory = factory
        self.onCompleteSelection = onCompleteSelection
        self.viewModel = factory.buildCarbItemsViewModel()
        super.init()
    }

    public override func start() -> CarbItemsView {
        factory.buildCarbItemsView(
            viewModel: viewModel,
            coordinator: self
        )
    }
}

// MARK: - Navigation

public extension CarbItemsCoordinator {
    func pushCarbItemForm(for existingItem: CarbItem? = nil) {
        push(.form(existingItem: existingItem))
    }

    @ViewBuilder
    func buildFormView(for existingItem: CarbItem? = nil) -> CarbItemFormView {
        let saveAction: (CarbItem) -> Void = { [weak self] savedItem in
            Task { @MainActor in
                guard let self = self else { return }
                if let old = existingItem {
                    await self.viewModel.editUserCarbItem(newItem: savedItem, oldItem: old)
                } else {
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
