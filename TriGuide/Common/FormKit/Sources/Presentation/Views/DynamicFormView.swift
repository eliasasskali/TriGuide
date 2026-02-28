//
// TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI

public struct DynamicFormView: View {
    @StateObject private var viewModel: FormViewModel
    private let sections: [FormSection]
    public var onSubmit: (FormResult) -> Void

    public init(
        sections: [FormSection],
        initial: FormResult? = nil,
        onSubmit: @escaping (FormResult) -> Void
    ) {
        self.sections = sections
        _viewModel = StateObject(
            wrappedValue: FormViewModel(
                fields: sections.flatMap { $0.fields },
                initial: initial
            )
        )
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(spacing: 0) {
            Form {
                ForEach(sections.indices, id: \.self) { index in
                    let section = sections[index]
                    Section(header: section.title.map(Text.init)) {
                        ForEach(section.fields, id: \.id) { field in
                            FieldView(
                                field: field,
                                value: Binding(
                                    get: { viewModel.values[field.id] ?? "" },
                                    set: { viewModel.updateValue(field.id, value: $0) }
                                ),
                                error: Binding(
                                    get: { viewModel.errors[field.id] },
                                    set: { _ in viewModel.clearError(field.id) }
                                )
                            )
                        }
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))

            ActionButton(
                Localizables.Common.save,
                style: .primary,
                action: handleSave
            )
            .background(Color(uiColor: .systemGroupedBackground))
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - Private methods

private extension DynamicFormView {
    func handleSave() {
        let result = viewModel.submit()
        switch result {
        case let .success(formResult):
            onSubmit(formResult)
        case .failure:
            break
        }
    }
}

// MARK: - Previews

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    var sections: [FormSection] {
        [
            FormSection(
                title: "Section 1",
                fields: fieldsSection1
            ),
            FormSection(
                title: "Section 2",
                fields: fieldsSection2
            ),
        ]
    }

    var fieldsSection1: [FieldDescriptor] {
        [
            FieldDescriptor(
                id: "Required text",
                label: "Required Text",
                placeholder: "Enter text",
                type: .text,
                required: true
            ),
            FieldDescriptor(
                id: "Not required text",
                label: "Not Required Text",
                placeholder: "Enter Text",
                type: .text
            ),
            FieldDescriptor(
                id: "Required decimal",
                label: "Required decimal",
                placeholder: "Enter decimal",
                type: .decimal,
                required: true,
                min: 0
            ),
        ]
    }

    var fieldsSection2: [FieldDescriptor] {
        [
            FieldDescriptor(
                id: "Not required decimal between 1 and 10",
                label: "Not required decimal between 1 and 10",
                placeholder: "Enter decimal",
                type: .decimal,
                min: 1,
                max: 10
            ),
            FieldDescriptor(
                id: "Not required integer",
                label: "Sodium (mg)",
                placeholder: "Sodium (mg)",
                type: .integer
            ),
            FieldDescriptor(
                id: "Toggle",
                label: "Toggle",
                placeholder: "Toggle",
                type: .toggle,
                required: true
            ),
            FieldDescriptor(
                id: "Required Picker",
                label: "Required Picker",
                type: .picker,
                required: true,
                options: [
                    .init(id: "One", label: "One"),
                    .init(id: "Two", label: "Two"),
                ]
            ),
        ]
    }

    var body: some View {
        DynamicFormView(
            sections: sections,
            onSubmit: { _ in }
        )
    }
}
