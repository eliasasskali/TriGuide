//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

extension CarbItem {
    func toDto() -> CarbItemDto {
        CarbItemDto(
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
