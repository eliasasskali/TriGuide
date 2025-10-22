//
//  TriGuide 2025
//

import Foundation
import Combine

class PaceCalculatorViewModel: ObservableObject {
    let paceCalculator: PaceCalculator

    @Published var distance: Double? {
        didSet { updateFromPaceOrSpeed() }
    }

    @Published var duration: TimeInterval? {
        didSet {
            guard !isUpdating else { return }
            updateFromDuration()
        }
    }

    @Published var pace: TimeInterval? {
        didSet {
            guard !isUpdating else { return }
            updateFromPaceOrSpeed()
        }
    }

    @Published var speed: Double? {
        didSet {
            guard !isUpdating else { return }
            updateFromPaceOrSpeed()
        }
    }

    @Published var paceUnit: SupportedUnit? {
        didSet {
            recalculateAll()
        }
    }

    @Published var distanceUnit: DistanceUnit? {
        didSet { updateFromPaceOrSpeed() }
    }

    private var isUpdating = false

    init(
        paceCalculator: PaceCalculator,
        distance: Double? = nil,
        duration: TimeInterval? = nil,
        pace: TimeInterval? = nil,
        speed: Double? = nil,
        paceUnit: SupportedUnit? = nil
    ) {
        self.paceCalculator = paceCalculator
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.speed = speed
        self.paceUnit = paceUnit
        self.distanceUnit = paceUnit?.distanceUnit ?? .kilometers
    }
}

// MARK: - Private methods

private extension PaceCalculatorViewModel {
    func recalculateAll() {
        guard let duration, let distance, let paceUnit else { return }
        isUpdating = true
        let paceOrSpeed = paceCalculator.calculatePace(duration: duration, distance: distance, paceUnit: paceUnit)
        if [.kmPerHour, .milesPerHour].contains(paceUnit) {
            speed = paceOrSpeed
            pace = nil
        } else {
            pace = paceOrSpeed
            speed = nil
        }
        isUpdating = false
    }

    func updateFromPaceOrSpeed() {
        guard let paceOrSpeed = pace ?? speed,
              let distance,
              let paceUnit
        else { return }
        isUpdating = true
        duration = paceCalculator.calculateTime(pace: paceOrSpeed, distance: distance, paceUnit: paceUnit)
        isUpdating = false
    }

    func updateFromDuration() {
        guard let duration, let distance, let paceUnit else { return }
        isUpdating = true
        let paceOrSpeed = paceCalculator.calculatePace(duration: duration, distance: distance, paceUnit: paceUnit)
        if [.kmPerHour, .milesPerHour].contains(paceUnit) {
            speed = paceOrSpeed
            pace = nil
        } else {
            pace = paceOrSpeed
            speed = nil
        }
        isUpdating = false
    }
}
