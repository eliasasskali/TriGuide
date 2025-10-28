//
// TriGuide 2025
//

import Foundation

public struct CarbItem: Sendable {
    let id: String
    let name: String
    let gramsOfCarbs: Double
    let caffeine: Double?
    let waterVolumeML: Double?
    let type: CarbType
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
