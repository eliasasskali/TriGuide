//
// TriGuide 2025
//

import XCTest
@testable import RaceCalculatorSPM

final class CyclingPaceCalculatorTests: XCTestCase {
    var sut: CyclingPaceCalculator!

    override func setUp() {
        super.setUp()
        sut = CyclingPaceCalculator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private let accuracy: Double = 0.01
}

extension CyclingPaceCalculatorTests {

    // MARK: - calculatePace (speed in km/h or mph)

    func testCyclingPaceCalculator_whenCalculatingPace_decimalKmPerHour_case1_thenReturnsExpectedSpeed() throws {
        // Arrange: distance = 12,345 km, duration = 1800 s (20 min) -> speed = 24,690 km/h
        let distance = 12_345.0
        let duration = TimeInterval(1800)
        let expectedSpeed = 24.690

        // Act
        let speed = sut.calculatePace(duration: duration, distance: distance, paceUnit: .kmPerHour)

        // Assert
        XCTAssertNotNil(speed)
        XCTAssertEqual(speed!, expectedSpeed, accuracy: accuracy)
    }

    func testCyclingPaceCalculator_whenCalculatingPace_decimalKmPerHour_case2_thenReturnsExpectedSpeed() throws {
        // Arrange: distance = 20 km, duration = 3720 s (1 hr 2 min) -> speed = ~19,355 km/h
        let distance = 20_000.0
        let duration = TimeInterval(3720)
        let expectedSpeed = 19.355

        // Act
        let speed = sut.calculatePace(duration: duration, distance: distance, paceUnit: .kmPerHour)

        // Assert
        XCTAssertNotNil(speed)
        XCTAssertEqual(speed!, expectedSpeed, accuracy: accuracy)
    }

    func testCyclingPaceCalculator_whenCalculatingPace_decimalMilesPerHour_thenReturnsExpectedSpeed() throws {
        // Arrange: distance = 50 km (~31,069 mi), duration = 7200 s (2 h) -> speed (mph) = ~15,5342798059 mph
        let distance = 50_000.0
        let duration = TimeInterval(7200)
        let expectedSpeed = 15.534

        // Act
        let speed = sut.calculatePace(duration: duration, distance: distance, paceUnit: .milesPerHour)

        // Assert
        XCTAssertNotNil(speed)
        XCTAssertEqual(speed!, expectedSpeed, accuracy: accuracy)
    }

    func testCyclingPaceCalculator_whenCalculatingPace_withZeroOrNegativeInputs_thenReturnsNil() {
        // Arrange
        let zeroDuration = TimeInterval(0)
        let zeroDistance = 0.0
        let negativeDuration = TimeInterval(-1)
        let negativeDistance = -100.0

        // Act / Assert
        XCTAssertNil(sut.calculatePace(duration: zeroDuration, distance: 10_000, paceUnit: .kmPerHour))
        XCTAssertNil(sut.calculatePace(duration: 1000, distance: zeroDistance, paceUnit: .kmPerHour))

        XCTAssertNil(sut.calculatePace(duration: negativeDuration, distance: 1000, paceUnit: .kmPerHour))
        XCTAssertNil(sut.calculatePace(duration: 1000, distance: negativeDistance, paceUnit: .kmPerHour))
    }

    func testCyclingPaceCalculator_whenCalculatingPace_preservesFractionalSpeed() throws {
        // Arrange: 7 meters in 1 second -> speed = 25,2 km/h
        let distance = 7.0
        let duration = TimeInterval(1)
        let expectedSpeed = 25.2

        // Act
        let speed = sut.calculatePace(duration: duration, distance: distance, paceUnit: .kmPerHour)

        // Assert
        XCTAssertNotNil(speed)
        XCTAssertEqual(speed!, expectedSpeed, accuracy: accuracy)
    }
}

extension CyclingPaceCalculatorTests {

    // MARK: - calculateTime

    func testCyclingPaceCalculator_whenCalculatingTime_forDecimalKmPerHour_case1_thenReturnsExpectedTime() throws {
        // Arrange: speed = 12,345 km/h, distance = 12,345 km -> expected time = 3600 s
        let speed = 12.345
        let distance = 12_345.0
        let expectedTime = 3600.0

        // Act
        let time = sut.calculateTime(pace: speed, distance: distance, paceUnit: .kmPerHour)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testCyclingPaceCalculator_whenCalculatingTime_forDecimalKmPerHour_case2_thenReturnsExpectedTime() throws {
        // Arrange: speed = ~19,35 km/h, distance = 20 km -> expected time = 3720 s
        let speed = 19.35
        let distance = 20_000.0
        let expectedTime = 3720.93

        // Act
        let time = sut.calculateTime(pace: speed, distance: distance, paceUnit: .kmPerHour)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testCyclingPaceCalculator_whenCalculatingTime_forDecimalMilesPerHour_thenReturnsExpectedTime() throws {
        // Arrange: speed = 15.534 mph, distance = 50 km -> expected time = 7200 s
        let speed = 15.534
        let distance = 50_000.0
        let expectedTime = 7200.1296

        // Act
        let time = sut.calculateTime(pace: speed, distance: distance, paceUnit: .milesPerHour)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testCyclingPaceCalculator_whenCalculatingTime_withZeroSpeed_thenReturnsNil() {
        // Arrange: zero speed
        let speed = 0.0
        let distance = 1000.0

        // Act
        let time = sut.calculateTime(pace: speed, distance: distance, paceUnit: .kmPerHour)

        // Assert
        XCTAssertNil(time)
    }

    func testCyclingPaceCalculator_whenCalculatingTime_preservesFractionalSeconds() throws {
        // Arrange: speed = 19,5 km/h, distance = 1234 m -> time = 227,82 s
        let speed = 19.5
        let distance = 1_234.0

        // Act
        let time = sut.calculateTime(pace: speed, distance: distance, paceUnit: .kmPerHour)

        // Assert
        XCTAssertNotNil(time)
        let fractionalPart = time! - floor(time!)
        XCTAssertGreaterThan(fractionalPart, 0.0, "Expected fractional seconds to be preserved (not truncated).")
    }
}

extension CyclingPaceCalculatorTests {

    // MARK: - formatPace (string formatting)

    func testCyclingPaceCalculator_whenFormattingSpeed_decimalKilometersPerHour_thenReturnsOneDecimalString() {
        // Arrange: speed = 12,345 km/h -> formatted "12,34 km/h" (one decimal)
        let speed = 12.345
        let expected = "12,34 km/h"

        // Act
        let formatted = sut.formatPace(speed, with: .kmPerHour)

        // Assert
        XCTAssertEqual(formatted, expected)
    }

    func testCyclingPaceCalculator_whenFormattingSpeed_decimalMilesPerHour_thenReturnsOneDecimalString() {
        // Arrange: speed = ~15,5343 -> formatted "15,53 mph"
        let speed = 15.5343
        let expected = "15,53 mph"

        // Act
        let formatted = sut.formatPace(speed, with: .milesPerHour)

        // Assert
        XCTAssertEqual(formatted, expected)
    }
}
