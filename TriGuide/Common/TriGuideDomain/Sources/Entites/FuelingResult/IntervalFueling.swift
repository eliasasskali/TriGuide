//
// TriGuide 2025
//

import Foundation

public struct IntervalFueling: Sendable, Hashable, Equatable, Codable {
    // MARK: - Dependencies

    public let duration: TimeInterval
    public let index: Int
    public let carbGrams: Double
    public let caffeine: Double
    public let waterVolumeML: Double

    // MARK: - Initializer

    public init(
        duration: TimeInterval,
        hourIndex: Int,
        carbGrams: Double,
        caffeine: Double,
        waterVolumeML: Double
    ) {
        self.duration = duration
        index = hourIndex
        self.carbGrams = carbGrams
        self.caffeine = caffeine
        self.waterVolumeML = waterVolumeML
    }

    // MARK: - Computed Properties

    public var formatted: String {
        let startTime = duration * Double(index)
        let endTime = duration * Double(index + 1)
        let formattedStart = TimeInterval(startTime).formattedAsHourMin
        let formattedEnd = TimeInterval(endTime).formattedAsHourMin

        return "\(formattedStart) - \(formattedEnd)"
    }
}
