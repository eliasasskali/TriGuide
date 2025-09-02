//
//  TriathlonTimeViewModel.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 12/7/25.
//

import Foundation

class TriathlonTimeViewModel: ObservableObject {
    @Published var swimTime: TimeInterval?
    @Published var t1Time: TimeInterval?
    @Published var cyclingTime: TimeInterval?
    @Published var t2Time: TimeInterval?
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
