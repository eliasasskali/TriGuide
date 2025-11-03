//
// TriGuide 2025
//

import SwiftUI

struct FieldView: View {
    let field: FieldDescriptor
    @Binding var value: String
    @Binding var error: String?

    var body: some View {
        fieldView(field)
    }

    @ViewBuilder
    private func fieldView(_ field: FieldDescriptor) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if [.text, .integer, .decimal].contains(field.type) {
                Text(field.label)
                    .font(.Custom.Medium.font3)
                    .foregroundColor(.secondary)
            }

            switch field.type {
            case .text:
                VStack(alignment: .leading, spacing: 8) {
                    TextField(field.placeholder ?? field.label, text: $value)
                        .autocorrectionDisabled(true)
                    validationText(for: field)
                }

            case .integer:
                VStack(alignment: .leading, spacing: 8) {
                    TextField(field.placeholder ?? field.label, text: $value)
                        .keyboardType(.numberPad)
                        .onChange(of: value) { _, new in
                            value = new.filteredNumeric(allowDecimal: false)
                        }
                    validationText(for: field)
                }

            case .decimal:
                VStack(alignment: .leading, spacing: 8) {
                    TextField(field.placeholder ?? field.label, text: $value)
                        .keyboardType(.decimalPad)
                        .onChange(of: value) { _, new in
                            value = new.filteredNumeric(allowDecimal: true, maxDecimalPlaces: 3)
                        }
                    validationText(for: field)
                }

            case .picker:
                VStack(alignment: .leading, spacing: 8) {
                    Picker(field.label, selection: $value) {
                        if let options = field.pickerOptions {
                            ForEach(options, id: \.id) { option in
                                Text(option.label).tag(option.id)
                            }
                        }
                    }
                    validationText(for: field)
                }

            case .toggle:
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: Binding(
                        get: { value.lowercased() == "true" },
                        set: { value = $0 ? "true" : "false" }
                    )) {
                        Text(field.label)
                    }
                    validationText(for: field)
                }
            }
        }
    }
}

// MARK: - Private helpers

private extension FieldView {
    @ViewBuilder
    private func validationText(for field: FieldDescriptor) -> some View {
        if let explicit = error, !explicit.isEmpty {
            Text(explicit)
                .foregroundColor(.red)
                .font(.Custom.Medium.font2)
        } else if let validationError = Validator.validate(descriptor: field, value: value) {
            Text(validationError.localizedDescription)
                .foregroundColor(.red)
                .font(.Custom.Medium.font2)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Small helpers for sanitization

fileprivate extension String {
    static var decimalSeparator: Character {
        Character(Locale.current.decimalSeparator ?? ".")
    }

    func filteredNumeric(allowDecimal: Bool = false, maxDecimalPlaces: Int? = nil) -> String {
        let sep = String.decimalSeparator
        var out = ""
        var seenDecimal = false
        for ch in self {
            if ch.isWholeNumber {
                out.append(ch)
            } else if allowDecimal && ch == sep && !seenDecimal {
                out.append(ch)
                seenDecimal = true
            }
        }
        if allowDecimal, let max = maxDecimalPlaces, let idx = out.firstIndex(of: sep) {
            let fractionalStart = out.index(after: idx)
            let fractional = out[fractionalStart...]
            if fractional.count > max {
                let endIndex = out.index(fractionalStart, offsetBy: max)
                out = String(out[..<endIndex])
            }
        }
        return out
    }
}
