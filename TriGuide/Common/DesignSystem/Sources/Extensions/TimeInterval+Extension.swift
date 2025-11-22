//
//  TriGuide 2025
//

import Foundation

public extension TimeInterval {
    var formattedAsHourMinSec: String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours == 0 {
            return "\(minutes):" + String(format: "%02d", seconds)
        }

        return "\(hours):" + String(format: "%02d:%02d", minutes, seconds)
    }

    func roundToMultiple(
        of seconds: Double = 300.0,
        rule: FloatingPointRoundingRule
    ) -> TimeInterval {
        (self / seconds).rounded(rule) * seconds
    }
}
