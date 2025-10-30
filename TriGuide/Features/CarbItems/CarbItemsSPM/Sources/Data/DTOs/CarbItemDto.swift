//
// TriGuide 2025
//

import Foundation

public struct CarbItemDto: Codable, Sendable {
    let id: String
    let name: String
    let gramsOfCarbs: Double
    let caffeine: Double?
    let sodium: Double?
    let waterVolumeML: Double?
    let type: CarbType
    let brand: String?
}
