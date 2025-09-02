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
            unit: .minPerKm
        )

        XCTAssertEqual(pace, "3:06 min/km")
    }

    func testRunPaceCalculator_givenMinPerMileUnits_returnsCorrectPace() async throws {
        let sut = RunningPaceCalculator()

        let pace = sut.calculatePace(
            duration: 1858,
            distance: 10000,
            unit: .minPerMile
        )

        XCTAssertEqual(pace, "4:59 min/mi")
    }

    // MARK: - Swimming

    func testSwimmingPaceCalculator_givenMinPer100mUnits_returnsCorrectPace() async throws {
        let sut = SwimmingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 1050,
            distance: 1500,
            unit: .minPer100m
        )

        XCTAssertEqual(pace, "1:10 min/100m")
    }

    func testRunPaceCalculator_givenMinPer100yardsUnits_returnsCorrectPace() async throws {
        let sut = SwimmingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 1215,
            distance: 1500,
            unit: .minPer100yds
        )

        XCTAssertEqual(pace, "1:21 min/100yds")
    }

    // MARK: - Cycling

    func testCyclingPaceCalculator_givenKphUnits_returnsCorrectSpeed() async throws {
        let sut = CyclingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 14400,
            distance: 180000,
            unit: .kmPerHour
        )

        XCTAssertEqual(pace, "45.00 km/h")
    }

    func testCyclingPaceCalculator_givenMphUnits_returnsCorrectSpeed() async throws {
        let sut = CyclingPaceCalculator()

        let pace = sut.calculatePace(
            duration: 9000,
            distance: 90000,
            unit: .milesPerHour
        )

        XCTAssertEqual(pace, "22.37 mph")
    }
}
