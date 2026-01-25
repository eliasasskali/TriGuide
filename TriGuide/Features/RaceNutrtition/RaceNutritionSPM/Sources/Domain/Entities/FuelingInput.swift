//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

public struct FuelingInput {

    // MARK: - Dependencies

    public let carbItemSelection: [CarbItemSelection]
    public let carbsTarget: Double
    public let duration: TimeInterval
    public let sport: SupportedSport
    public let startBuffer: TimeInterval
    public let endBuffer: TimeInterval
    public let minCarbSpacing: TimeInterval
    public let minCaffeineSpacing: TimeInterval
    public let maxCaffeinePerDose: Double?

    // MARK: - Initializer

    public init(
        carbItemSelection: [CarbItemSelection],
        carbsTarget: Double,
        duration: TimeInterval,
        sport: SupportedSport,
        startBuffer: TimeInterval = 15 * 60,
        endBuffer: TimeInterval = 10 * 60,
        minCarbSpacing: TimeInterval = 10 * 60,
        minCaffeineSpacing: TimeInterval = 45 * 60,
        maxCaffeinePerDose: Double? = nil
    ) {
        self.carbItemSelection = carbItemSelection
        self.carbsTarget = carbsTarget
        self.duration = duration
        self.sport = sport
        self.startBuffer = startBuffer
        self.endBuffer = endBuffer
        self.minCarbSpacing = minCarbSpacing
        self.minCaffeineSpacing = minCaffeineSpacing
        self.maxCaffeinePerDose = maxCaffeinePerDose
    }
}
