//
//  TriGuide 2025
//

import Foundation

public enum CarbType: String, Codable, Sendable, CaseIterable {
    case solid
    case drink
    case gel
    case other
}

// MARK: - Decodable

public extension CarbType {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = CarbType(rawValue: rawValue) ?? .other
    }
}
