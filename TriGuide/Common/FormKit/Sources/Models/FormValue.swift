//
// TriGuide 2025
//

import Foundation

public typealias FormResult = [String: FormValue]

public enum FormValue: Codable, Equatable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case none

    enum CodingKeys: String, CodingKey {
        case type, value
    }

    enum ValueType: String, Codable {
        case string, int, double, bool, none
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .string(s):
            try container.encode(ValueType.string, forKey: .type)
            try container.encode(s, forKey: .value)
        case let .int(i):
            try container.encode(ValueType.int, forKey: .type)
            try container.encode(i, forKey: .value)
        case let .double(d):
            try container.encode(ValueType.double, forKey: .type)
            try container.encode(d, forKey: .value)
        case let .bool(b):
            try container.encode(ValueType.bool, forKey: .type)
            try container.encode(b, forKey: .value)
        case .none:
            try container.encode(ValueType.none, forKey: .type)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)
        switch type {
        case .string:
            let v = try container.decode(String.self, forKey: .value)
            self = .string(v)
        case .int:
            let v = try container.decode(Int.self, forKey: .value)
            self = .int(v)
        case .double:
            let v = try container.decode(Double.self, forKey: .value)
            self = .double(v)
        case .bool:
            let v = try container.decode(Bool.self, forKey: .value)
            self = .bool(v)
        case .none:
            self = .none
        }
    }

    public var stringValue: String {
        switch self {
        case let .string(s):
            return s
        case let .int(i):
            return String(i)
        case let .double(d):
            return String(d)
        case let .bool(b):
            return b ? "true" : "false"
        case .none:
            return ""
        }
    }

    public static func formValue(from raw: String, type: FormFieldType) -> FormValue {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .none }

        switch type {
        case .text:
            return .string(trimmed)
        case .integer:
            if let i = Int(trimmed) {
                return .int(i)
            }
            return .none
        case .decimal:
            let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
            if let d = Double(normalized) {
                return .double(d)
            }
            return .none
        case .picker:
            return .string(trimmed)
        case .toggle:
            let lower = trimmed.lowercased()
            if lower == "true" || lower == "1" {
                return .bool(true)
            }
            return .bool(false)
        }
    }
}
