//
// TriGuide 2025
//

import Combine
import Foundation

// MARK: - Wrapper for form result values

public struct FormValidationError: Error, Equatable {
    public let errors: [String: String]

    public init(errors: [String: String]) {
        self.errors = errors
    }
}

// MARK: - FormViewModel

@MainActor
public final class FormViewModel: ObservableObject {
    public let fields: [FieldDescriptor]

    @Published public private(set) var values: [String: String]
    @Published public private(set) var errors: [String: String]

    public init(fields: [FieldDescriptor], initial: FormResult? = nil) {
        self.fields = fields
        var initialValues: [String: String] = [:]
        for field in fields {
            if let initial, let value = initial[field.id] {
                initialValues[field.id] = value.stringValue
            } else {
                initialValues[field.id] = ""
            }
        }
        values = initialValues
        errors = [:]
    }

    public func updateValue(_ id: String, value: String) {
        values[id] = value
        errors[id] = nil
    }

    public func clearError(_ id: String) {
        errors[id] = nil
    }

    @discardableResult
    public func validate() -> Bool {
        var foundError = false
        var nextErrors: [String: String] = [:]

        for field in fields {
            let raw = values[field.id] ?? ""
            if let validationError = Validator.validate(descriptor: field, value: raw) {
                nextErrors[field.id] = validationError.localizedDescription
                foundError = true
            } else {
                // keep explicit error nil
            }
        }

        errors = nextErrors

        return !foundError
    }

    public func buildResult() -> FormResult {
        var result: FormResult = [:]
        for field in fields {
            let raw = values[field.id] ?? ""
            result[field.id] = FormValue.formValue(from: raw, type: field.type)
        }
        return result
    }

    public func submit() -> Result<FormResult, FormValidationError> {
        if validate() {
            return .success(buildResult())
        } else {
            return .failure(FormValidationError(errors: errors))
        }
    }
}
