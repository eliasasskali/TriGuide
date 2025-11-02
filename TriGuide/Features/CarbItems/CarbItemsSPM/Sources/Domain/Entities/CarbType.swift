//
//  TriGuide 2025
//

import Foundation

enum CarbType: String, Codable, CaseIterable {
    case solid
    case drink
    case gel
    case other
}

// MARK: - Decodable

extension CarbType {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = CarbType(rawValue: rawValue) ?? .other
    }
}
