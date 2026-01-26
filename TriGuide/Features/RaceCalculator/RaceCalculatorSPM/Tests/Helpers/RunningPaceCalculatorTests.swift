//
// TriGuide 2025
//

import XCTest
@testable import RaceCalculatorSPM

final class RunningPaceCalculatorTests: XCTestCase {
    var sut: RunningPaceCalculator!

    override func setUp() {
        super.setUp()
        sut = RunningPaceCalculator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private let accuracy: Double = 0.01
}

extension RunningPaceCalculatorTests {

    // MARK: - calculatePace

    func testRunningPaceCalculator_whenCalculatingPace_forHalfMarathonElite_thenReturnsExpectedPace() throws {
        // Arrange: 21,097 km in 59:59 (3599 s) -> pace = 170,59 s/km
        let duration = TimeInterval(3599)
        let distance = 21_097.0
        let expectedPace = 170.59

        // Act
        let pace = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPerKm)

        // Assert
        XCTAssertNotNil(pace)
        XCTAssertEqual(pace!, expectedPace, accuracy: accuracy)
    }

    func testRunningPaceCalculator_whenCalculatingPace_for5kSub15_thenReturnsExpectedPace() throws {
        // Arrange: 5000m in 14:59 (899 s) -> pace = 899 / 5 = 179,8 s/km
        let duration = TimeInterval(899)
        let distance = 5_000.0
        let expectedPace = 179.8

        // Act
        let pace = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPerKm)

        // Assert
        XCTAssertNotNil(pace)
        XCTAssertEqual(pace!, expectedPace, accuracy: accuracy)
    }

    func testRunningPaceCalculator_whenCalculatingPace_forMarathonSub3h_thenReturnsExpectedPace() throws {
        // Arrange: 42,195 km in 2:59:59 (10799 s) -> pace = 255,93 s/km
        let duration = TimeInterval(10799)
        let distance = 42_195.0
        let expectedPace = 255.93

        // Act
        let pace = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPerKm)

        // Assert
        XCTAssertNotNil(pace)
        XCTAssertEqual(pace!, expectedPace, accuracy: accuracy)
    }

    func testRunningPaceCalculator_whenCalculatingPace_for10k_minPerMile_thenReturnsExpectedPace() throws {
        // Arrange: 10k in 32:00 (1920 s), pace per mile = 308.99 s/mile = 5:09 min/mile
        let duration = TimeInterval(1920)
        let distance = 10_000.0
        let expectedPace = 308.99

        // Act
        let pace = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPerMile)

        // Assert
        XCTAssertNotNil(pace)
        XCTAssertEqual(pace!, expectedPace, accuracy: accuracy)
    }

    func testRunningPaceCalculator_whenCalculatingPace_withZeroOrInvalidInputs_thenReturnsNil() {
        XCTAssertNil(sut.calculatePace(duration: 0, distance: 5000, paceUnit: .minPerKm))
        XCTAssertNil(sut.calculatePace(duration: 3600, distance: 0, paceUnit: .minPerKm))
        XCTAssertNil(sut.calculatePace(duration: -3600, distance: 5000, paceUnit: .minPerKm))
    }
}


extension RunningPaceCalculatorTests {

    // MARK: - calculateTime

    func testRunningPaceCalculator_whenCalculatingTime_forHalfMarathonAt4minPerKm_thenReturnsExpectedTime() throws {
        // Arrange: 4:00 min/km = 240 s/km, distance = 21,097 km -> time = 5063,28 s = 1:24:23
        let pace = 240.0
        let distance = 21_097.0
        let expectedTime = 5063.28

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPerKm)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testRunningPaceCalculator_whenCalculatingTime_forMarathonSub3h_thenReturnsExpectedTime() throws {
        // Arrange: pace = 255,9 s/km, distance = 42,195 km -> 10799 s
        let pace = 255.9
        let distance = 42_195.0
        let expectedTime = 10797.7005

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPerKm)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testRunningPaceCalculator_whenCalculatingTime_for5kAt3minPerKm_thenReturnsExpectedTime() throws {
        // Arrange: 3:00 min/km = 180 s/km, distance = 5 km -> time = 900 s
        let pace = 180.0
        let distance = 5_000.0
        let expectedTime = 900.0

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPerKm)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testRunningPaceCalculator_whenCalculatingTime_for10kAt5minPerMile_thenReturnsExpectedTime() throws {
        // Arrange: 5 min/mile = 300 s/mile, distance = 10,000 m -> time = 1863,2 s
        let pace = 300.0
        let distance = 10_000.0
        let expectedTime = 1864.11

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPerMile)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }
}


extension RunningPaceCalculatorTests {

    // MARK: - formatPace

    func testRunningPaceCalculator_whenFormattingPace_minPerKm_thenReturnsExpectedString() {
        // Arrange
        let paceInSeconds = 185.0 // 3:05 min/km
        let expected = "3:05 min/km"

        // Act
        let formattedPace = sut.formatPace(paceInSeconds, with: .minPerKm)

        // Assert
        XCTAssertEqual(formattedPace, expected)
    }

    func testRunningPaceCalculator_whenFormattingPace_minPerMile_thenReturnsExpectedString() {
        // Arrange
        let paceInSeconds = 610.0 // 10:10 min/mi
        let expected = "10:10 min/mi"

        // Act
        let formattedPace = sut.formatPace(paceInSeconds, with: .minPerMile)

        // Assert
        XCTAssertEqual(formattedPace, expected)
    }
}
