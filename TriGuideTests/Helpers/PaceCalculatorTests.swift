//
//  TriGuide 2025
//

import XCTest
@testable import TriGuide
import Testing

class PaceCalculatorTests: XCTestCase {

    // MARK: - Running

    func testRunPaceCalculator_givenMinPerKmUnits_returnsCorrectPace() async throws {
        let sut = RunningPaceCalculator()

        let pace = sut.calculatePace(
            duration: 929,
            distance: 5000,
            paceUnit: .minPerKm
        )
        let formattedPace = sut.formatPace(pace ?? 0, with: .minPerKm)

        XCTAssertEqual(formattedPace, "3:06 min/km")
    }

    func testRunPaceCalculator_givenMinPerMileUnits_returnsCorrectPace() async throws {
        let sut = RunningPaceCalculator()

        let pace = sut.calculatePace(
            duration: 1858,
            distance: 10000,
            paceUnit: .minPerMile
        )

        let formattedPace = sut.formatPace(pace ?? 0, with: .minPerMile)

        XCTAssertEqual(formattedPace, "4:59 min/mi")
    }

    // MARK: - Swimming

    func testSwimmingPaceCalculator_givenMinPer100mUnits_returnsCorrectPace() async throws {
        let sut = SwimmingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 1050,
            distance: 1500,
            paceUnit: .minPer100m
        )
        
        let formattedPace = sut.formatPace(pace ?? 0, with: .minPer100m)

        XCTAssertEqual(formattedPace, "1:10 min/100m")
    }

    func testRunPaceCalculator_givenMinPer100yardsUnits_returnsCorrectPace() async throws {
        let sut = SwimmingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 1215,
            distance: 1500,
            paceUnit: .minPer100yds
        )
        
        let formattedPace = sut.formatPace(pace ?? 0, with: .minPer100yds)

        XCTAssertEqual(formattedPace, "1:21 min/100yds")
    }

    // MARK: - Cycling

    func testCyclingPaceCalculator_givenKphUnits_returnsCorrectSpeed() async throws {
        let sut = CyclingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 14400,
            distance: 180000,
            paceUnit: .kmPerHour
        )
        
        let formattedPace = sut.formatPace(pace ?? 0, with: .kmPerHour)

        XCTAssertEqual(formattedPace, "45.00 km/h")
    }

    func testCyclingPaceCalculator_givenMphUnits_returnsCorrectSpeed() async throws {
        let sut = CyclingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 9000,
            distance: 90000,
            paceUnit: .milesPerHour
        )
        
        let formattedPace = sut.formatPace(pace ?? 0, with: .milesPerHour)

        XCTAssertEqual(formattedPace, "22.37 mph")
    }
}
