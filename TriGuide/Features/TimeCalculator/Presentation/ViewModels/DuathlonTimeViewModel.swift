//
//  TriGuide 2025
//

import Foundation

class DuathlonTimeViewModel: ObservableObject {
    @Published var firstRunTime: TimeInterval?
    @Published var t1Time: TimeInterval?
    @Published var cyclingTime: TimeInterval?
    @Published var t2Time: TimeInterval?
    @Published var secondRunTime: TimeInterval?

    private var totalTime: TimeInterval? {
        let firstRun = firstRunTime ?? 0
        let t1 = t1Time ?? 0
        let cycling = cyclingTime ?? 0
        let t2 = t2Time ?? 0
        let secondRun = secondRunTime ?? 0

        return firstRun + t1 + cycling + t2 + secondRun
    }

    var formattedTotalTime: String {
        let total = Int(totalTime ?? 0)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
