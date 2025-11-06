//
//  TriGuide 2025
//

import Foundation
import Combine
import TriGuideDomain

@MainActor
public class PaceCalculatorViewModel: ObservableObject {
    let paceCalculator: PaceCalculator
    
    @Published var distance: Double? {
        didSet {
            guard !isUpdating else { return }
            if duration != nil && pace == nil && speed == nil {
                updatePaceOrSpeedFromDuration()
            } else {
                updateDurationFromPaceOrSpeed()
            }
        }
    }

    @Published var duration: TimeInterval? {
        didSet {
            guard !isUpdating else { return }
            updatePaceOrSpeedFromDuration()
        }
    }

    @Published var pace: TimeInterval? {
        didSet {
            guard !isUpdating else { return }
            updateDurationFromPaceOrSpeed()
        }
    }

    @Published var speed: Double? {
        didSet {
            guard !isUpdating else { return }
            updateDurationFromPaceOrSpeed()
        }
    }

    @Published var paceUnit: SpeedUnit? {
        didSet {
            guard !isUpdating else { return }
            updatePaceOrSpeedFromDuration()
        }
    }

    @Published var distanceUnit: DistanceUnit? {
        didSet {
            guard !isUpdating else { return }
            updateDurationFromPaceOrSpeed()
        }
    }

    private var isUpdating = false
    private var paceOrSpeed: Double? {
        pace ?? speed
    }

    public init(
        paceCalculator: PaceCalculator,
        distance: Double? = nil,
        duration: TimeInterval? = nil,
        pace: TimeInterval? = nil,
        speed: Double? = nil,
        paceUnit: SpeedUnit? = nil
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
        defer { isUpdating = false }

        let paceOrSpeed = paceCalculator.calculatePace(duration: duration, distance: distance, paceUnit: paceUnit)
        if [.kmPerHour, .milesPerHour].contains(paceUnit) {
            speed = paceOrSpeed
            pace = nil
        } else {
            pace = paceOrSpeed
            speed = nil
        }
    }

    func updatePaceOrSpeedFromDuration() {
        guard let duration, let paceUnit else { return }
        guard let distance else {
            updateDistance()
            return
        }
        isUpdating = true
        defer { isUpdating = false }

        let paceOrSpeed = paceCalculator.calculatePace(duration: duration, distance: distance, paceUnit: paceUnit)
        if [.kmPerHour, .milesPerHour].contains(paceUnit) {
            speed = paceOrSpeed
            pace = nil
        } else {
            pace = paceOrSpeed
            speed = nil
        }
    }

    func updateDurationFromPaceOrSpeed() {
        guard let paceOrSpeed = pace ?? speed,
              let paceUnit
        else { return }

        guard let distance else {
            updateDistance()
            return
        }
        isUpdating = true
        defer { isUpdating = false }
        duration = paceCalculator.calculateTime(pace: paceOrSpeed, distance: distance, paceUnit: paceUnit)
    }

    func updateDistance() {
        guard distance == nil,
            let duration,
            let paceOrSpeed = pace ?? speed,
                let paceUnit
        else { return }
        isUpdating = true
        defer { isUpdating = false }

        distance = paceCalculator.calculateDistance(pace: paceOrSpeed, duration: duration, paceUnit: paceUnit)
    }
}
