//
//  PaceCalculatorViewModel.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 1/7/25.
//

import Foundation
import Combine

class PaceCalculatorViewModel: ObservableObject {
    let paceCalculator: PaceCalculator

    @Published var distance: Double? {
        didSet { recalculateAll() }
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
            updateFromPace()
        }
    }

    @Published var speed: Double? {
        didSet {
            guard !isUpdating else { return }
            updateFromSpeed()
        }
    }

    @Published var paceUnit: SupportedUnit? {
        didSet {
            recalculateAll()
        }
    }

    @Published var distanceUnit: DistanceUnit?

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

    private func recalculateAll() {
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

    private func updateFromPace() {
        guard let pace, let distance, let paceUnit else { return }
        isUpdating = true
        duration = paceCalculator.calculateTime(pace: pace, distance: distance, paceUnit: paceUnit)
        speed = nil
        isUpdating = false
    }

    private func updateFromSpeed() {
        guard let speed, let distance, let paceUnit else { return }
        isUpdating = true
        let time = paceCalculator.calculateTime(pace: speed, distance: distance, paceUnit: paceUnit)
        duration = time
        pace = nil
        isUpdating = false
    }

    private func updateFromDuration() {
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

