//
// TriGuide 2025
//

import Foundation

public struct CarbItem: Sendable, Decodable {
    let id: String
    let name: String
    let gramsOfCarbs: Double
    let caffeine: Double?
    let sodium: Double?
    let waterVolumeML: Double?
    let type: CarbType
    let brand: String?
    let isCustom: Bool

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
}

// MARK: - Hashable

extension CarbItem: Hashable {
    public static func == (lhs: CarbItem, rhs: CarbItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
