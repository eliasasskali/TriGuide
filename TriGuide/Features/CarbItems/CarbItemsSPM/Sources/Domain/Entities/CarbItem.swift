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
    public var isFavorite: Bool

    init(
        id: String,
        name: String,
        gramsOfCarbs: Double,
        caffeine: Double? = nil,
        sodium: Double? = nil,
        waterVolumeML: Double? = nil,
        type: CarbType,
        brand: String? = nil,
        isCustom: Bool = false,
        isFavorite: Bool = false
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
        self.isFavorite = isFavorite
    }
}

// MARK: - Hashable

extension CarbItem: Hashable {
    public static func == (lhs: CarbItem, rhs: CarbItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.gramsOfCarbs == rhs.gramsOfCarbs &&
        lhs.caffeine == rhs.caffeine &&
        lhs.sodium == rhs.sodium &&
        lhs.waterVolumeML == rhs.waterVolumeML &&
        lhs.type == rhs.type &&
        lhs.brand == rhs.brand &&
        lhs.isFavorite == rhs.isFavorite
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(gramsOfCarbs)
        hasher.combine(caffeine)
        hasher.combine(sodium)
        hasher.combine(waterVolumeML)
        hasher.combine(type)
        hasher.combine(brand)
        hasher.combine(isFavorite)
    }
}
