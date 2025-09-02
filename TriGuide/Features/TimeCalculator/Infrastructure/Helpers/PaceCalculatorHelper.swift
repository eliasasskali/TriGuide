//
//  TriGuide 2025
//

import Foundation

public struct PaceCalculatorHelper {
    static func formatPace(paceSeconds: Double, with unit: SupportedUnit) -> String {
        guard paceSeconds > 0 else { return "--" }

        let totalSeconds = Int(paceSeconds.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%d:%02d %@", minutes, seconds, unit.localized)
    }
}
