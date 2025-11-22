//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public struct CarbItemDto: Codable, Sendable {
    let id: String
    let name: String
    let gramsOfCarbs: Double
    let caffeine: Double?
    let sodium: Double?
    let waterVolumeML: Double?
    let type: CarbType
    let brand: String?

    init(
        id: String,
        name: String,
        gramsOfCarbs: Double,
        caffeine: Double? = nil,
        sodium: Double? = nil,
        waterVolumeML: Double? = nil,
        type: CarbType,
        brand: String? = nil
    ) {
        self.id = id
        self.name = name
        self.gramsOfCarbs = gramsOfCarbs
        self.caffeine = caffeine
        self.sodium = sodium
        self.waterVolumeML = waterVolumeML
        self.type = type
        self.brand = brand
    }
}
