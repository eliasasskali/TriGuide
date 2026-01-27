//
// TriGuide 2025
//

import Foundation
import Localization

// MARK: - ValidationError

public enum ValidationError: Error, Equatable {
    case required
    case invalidNumber
    case outOfRange(min: Double?, max: Double?)
    case regexMismatch
}

public extension ValidationError {
    var localizedDescription: String {
        switch self {
        case .required:
            return Localizables.FormErrors.requiredField
        case .invalidNumber:
            return Localizables.FormErrors.invalidNumber
        case let .outOfRange(min, max):
            if let min, let max {
                return Localizables.FormErrors.betweenMinAndMax(min: min, max: max)
            }
            if let min {
                return Localizables.FormErrors.biggerThan(min: min)
            }
            if let max {
                return Localizables.FormErrors.smallerThan(max: max)
            }
            return Localizables.FormErrors.outOfRange
        case .regexMismatch:
            return Localizables.FormErrors.invalidFormat
        }
    }
}

// MARK: - Validator

public enum Validator {
    public static func validate(descriptor: FieldDescriptor, value: String) -> ValidationError? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if descriptor.required, trimmed.isEmpty {
            return .required
        }

        switch descriptor.type {
        case .integer:
            if trimmed.isEmpty { return nil }
            if Int(trimmed) == nil { return .invalidNumber }
            if let min = descriptor.min, let val = Int(trimmed), Double(val) < min {
                return .outOfRange(min: descriptor.min, max: descriptor.max)
            }
            if let max = descriptor.max, let val = Int(trimmed), Double(val) > max {
                return .outOfRange(min: descriptor.min, max: descriptor.max)
            }
            return nil
        case .decimal:
            if trimmed.isEmpty { return nil }
            let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
            if Double(normalized) == nil { return .invalidNumber }
            if let num = Double(normalized) {
                if let min = descriptor.min, num < min {
                    return .outOfRange(min: descriptor.min, max: descriptor.max)
                }
                if let max = descriptor.max, num > max {
                    return .outOfRange(min: descriptor.min, max: descriptor.max)
                }
            }
            return nil
        case .text:
            if let regex = descriptor.regex, !trimmed.isEmpty {
                if let _ = trimmed.range(of: regex, options: .regularExpression) {
                    return nil
                } else {
                    return .regexMismatch
                }
            }
            return nil
        case .picker:
            if descriptor.required, trimmed.isEmpty {
                return .required
            }
            return nil
        case .toggle:
            return nil
        }
    }
}
