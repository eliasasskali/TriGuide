//
//  TriGuide 2025
//

import Foundation

class TriathlonTimeViewModel: ObservableObject {
    @Published var swimTime: TimeInterval?
    @Published var t1Time: TimeInterval? = 60
    @Published var cyclingTime: TimeInterval?
    @Published var t2Time: TimeInterval? = 60
    @Published var runningTime: TimeInterval?

    private var totalTime: TimeInterval? {
        let swim = swimTime ?? 0
        let t1 = t1Time ?? 0
        let cycling = cyclingTime ?? 0
        let t2 = t2Time ?? 0
        let running = runningTime ?? 0

        return swim + t1 + cycling + t2 + running
    }

    var formattedTotalTime: String {
        (totalTime ?? 0).formattedAsHourMinSec
    }

    func reset() {
        swimTime = nil
        t1Time = 60
        cyclingTime = nil
        t2Time = 60
        runningTime = nil
    }
}
