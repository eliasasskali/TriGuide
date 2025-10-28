//
// TriGuide 2025
//

import Foundation

extension CarbItemDto {
    func toDomain() -> CarbItem {
        CarbItem(
            id: self.id,
            name: self.name,
            gramsOfCarbs: self.gramsOfCarbs,
            caffeine: self.caffeine,
            waterVolumeML: self.waterVolumeML,
            type: self.type
        )
    }
}
