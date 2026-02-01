//
// TriGuide 2025
//

import FormKit
import Localization
import SwiftUI

public struct CarbItemFormView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Dependencies

    @StateObject private var viewModel: CarbItemFormViewModel

    // MARK: - Initializer

    public init(viewModel: CarbItemFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        DynamicFormView(
            sections: viewModel.sections,
            initial: viewModel.initialFormResult,
            onSubmit: { result in
                viewModel.handleSubmit(result: result)
                dismiss()
            }
        )
        .navigationTitle(
            viewModel.initialFormResult == nil ? Localizables.CarbItemForm.newCarbItem : Localizables.CarbItemForm.editCarbItem
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CarbItemFormView(
            viewModel: CarbItemFormViewModel(
                sections: [
                    .init(
                        title: "Section",
                        fields: [
                            .init(id: "field1", label: "field2", type: .text, required: true),
                        ]
                    ),
                ],
                saveAction: { _ in }
            )
        )
    }
}
