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
        (totalTime ?? 0).formattedAsHourMinSec
    }
}
