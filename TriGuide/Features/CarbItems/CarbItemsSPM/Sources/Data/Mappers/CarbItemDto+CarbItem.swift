//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

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
