//
// TriGuide 2025
//

import Foundation
import RaceCalculatorSPM
import TriGuideDomain

final class PaceCalculatorMock: PaceCalculator {
    let pace: Double?
    let time: Double?
    let distance: Double?
    let formattedPace: String
    let isTimeMocked: Bool

    init(
        pace: Double? = nil,
        time: Double? = nil,
        distance: Double? = nil,
        formattedPace: String = "",
        isTimeMocked: Bool = true
    ) {
        self.pace = pace
        self.time = time
        self.distance = distance
        self.formattedPace = formattedPace
        self.isTimeMocked = isTimeMocked
    }

    func calculatePace(
        duration _: TimeInterval,
        distance _: Double,
        paceUnit _: SpeedUnit
    ) -> Double? {
        return pace
    }

    func calculateTime(
        pace: Double,
        distance: Double,
        paceUnit: SpeedUnit
    ) -> Double? {
        guard !isTimeMocked else { return time }
        if paceUnit == .minPerKm {
            return pace * distance
        } else if paceUnit == .kmPerHour {
            return (distance / pace) * 3600
        } else if paceUnit == .minPer100m {
            return (distance / 100) * pace
        }
        return nil
    }

    func calculateDistance(
        pace _: Double,
        duration _: TimeInterval,
        paceUnit _: SpeedUnit
    ) -> Double? {
        distance
    }

    func formatPace(
        _: Double,
        with _: SpeedUnit
    ) -> String {
        formattedPace
    }
}
