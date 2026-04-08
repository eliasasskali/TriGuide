//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public struct CarbItemDto: Codable, Sendable {
    // MARK: - Dependencies

    let id: String
    let name: String
    let gramsOfCarbs: Double
    let caffeine: Double?
    let sodium: Double?
    let waterVolumeML: Double?
    let type: CarbType
    let brand: String?
    let isCustom: Bool

    // MARK: - Initializer

    init(
        id: String,
        name: String,
        gramsOfCarbs: Double,
        caffeine: Double? = nil,
        sodium: Double? = nil,
        waterVolumeML: Double? = nil,
        type: CarbType,
        brand: String? = nil,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.gramsOfCarbs = gramsOfCarbs
        self.caffeine = caffeine
        self.sodium = sodium
        self.waterVolumeML = waterVolumeML
        self.type = type
        self.brand = brand
        self.isCustom = isCustom
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        gramsOfCarbs = try container.decode(Double.self, forKey: .gramsOfCarbs)
        caffeine = try container.decodeIfPresent(Double.self, forKey: .caffeine)
        sodium = try container.decodeIfPresent(Double.self, forKey: .sodium)
        waterVolumeML = try container.decodeIfPresent(Double.self, forKey: .waterVolumeML)
        type = try container.decode(CarbType.self, forKey: .type)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        isCustom = try container.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false
    }
}
