//
// TriGuide 2025
//

import Foundation

extension CarbItem {
    func toDto() -> CarbItemDto {
        CarbItemDto(
            id: self.id,
            name: self.name,
            gramsOfCarbs: self.gramsOfCarbs,
            caffeine: self.caffeine,
            sodium: self.sodium,
            waterVolumeML: self.waterVolumeML,
            type: self.type,
            brand: self.brand
        )
    }
}
