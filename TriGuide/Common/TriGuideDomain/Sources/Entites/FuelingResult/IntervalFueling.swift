//
// TriGuide 2025
//

import Foundation

public struct IntervalFueling: Sendable, Hashable, Equatable {
    public let duration: TimeInterval
    public let hourIndex: Int
    public let carbGrams: Double
    public let caffeine: Double
    public let waterVolumeML: Double

    public init(
        duration: TimeInterval,
        hourIndex: Int,
        carbGrams: Double,
        caffeine: Double,
        waterVolumeML: Double
    ) {
        self.duration = duration
        self.hourIndex = hourIndex
        self.carbGrams = carbGrams
        self.caffeine = caffeine
        self.waterVolumeML = waterVolumeML
    }
}
