//
// TriGuide 2025
//

import Foundation

// MARK: - FormFieldType

public enum FormFieldType: String, Codable, Sendable {
    case text
    case integer
    case decimal
    case picker
    case toggle
}

// MARK: - FieldPickerOption

public struct FieldPickerOption: Codable, Hashable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

// MARK: - FieldDescriptor

public struct FieldDescriptor: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var label: String
    public var placeholder: String?
    public var type: FormFieldType
    public var required: Bool
    public var pickerOptions: [FieldPickerOption]?
    public var min: Double?
    public var max: Double?
    public var regex: String?

    public init(
        id: String,
        label: String,
        placeholder: String? = nil,
        type: FormFieldType = .text,
        required: Bool = false,
        options: [FieldPickerOption]? = nil,
        min: Double? = nil,
        max: Double? = nil,
        regex: String? = nil
    ) {
        self.id = id
        self.label = label
        self.placeholder = placeholder
        self.type = type
        self.required = required
        pickerOptions = options
        self.min = min
        self.max = max
        self.regex = regex
    }
}
