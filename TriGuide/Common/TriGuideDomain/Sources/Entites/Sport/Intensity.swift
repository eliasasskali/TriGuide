//
// TriGuide 2025
//

import Foundation
import Localization

public enum Intensity: String, CaseIterable {
    case low
    case moderate
    case high

    public var localized: String {
        switch self {
        case .low:
            return Localizables.Intensity.labelLow
        case .moderate:
            return Localizables.Intensity.labelMedium
        case .high:
            return Localizables.Intensity.labelHigh
        }
    }

    // Caps are conservative recommendations for "what to tell amateurs" to avoid GI distress.
    public var amateurGramsPerHourCap: Double {
        switch self {
        case .low:
            return 60
        case .moderate:
            return 90
        case .high:
            return 90
        }
    }
}
