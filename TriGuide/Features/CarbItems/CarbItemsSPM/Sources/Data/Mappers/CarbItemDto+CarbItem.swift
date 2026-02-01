//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - CarbItemDto to CarbItem

extension CarbItemDto {
    func toDomain() -> CarbItem {
        CarbItem(
            id: id,
            name: name,
            gramsOfCarbs: gramsOfCarbs,
            caffeine: caffeine,
            sodium: sodium,
            waterVolumeML: waterVolumeML,
            type: type,
            brand: brand
        )
    }
}
