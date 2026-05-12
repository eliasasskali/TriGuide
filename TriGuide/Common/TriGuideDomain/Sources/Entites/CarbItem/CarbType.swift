//
//  TriGuide 2025
//

import Foundation
import Localization

public enum CarbType: String, Codable, Sendable, CaseIterable {
    case solid
    case drink
    case gel
    case other

    public var localized: String {
        return switch self {
        case .solid:
            Localizables.CarbItems.typeSolid
        case .drink:
            Localizables.CarbItems.typeDrink
        case .gel:
            Localizables.CarbItems.typeGel
        case .other:
            Localizables.CarbItems.typeOther
        }
    }
}

// MARK: - Decodable

public extension CarbType {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = CarbType(rawValue: rawValue) ?? .other
    }
}
