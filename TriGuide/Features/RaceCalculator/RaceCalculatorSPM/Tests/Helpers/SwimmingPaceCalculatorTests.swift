//
// TriGuide 2025
//

@testable import RaceCalculatorSPM
import XCTest

final class SwimmingPaceCalculatorTests: XCTestCase {
    var sut: SwimmingPaceCalculator!

    override func setUp() {
        super.setUp()
        sut = SwimmingPaceCalculator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private let metersInYard: Double = 0.9144
    private let accuracy: Double = 0.01
}

extension SwimmingPaceCalculatorTests {
    // MARK: - calculatePace

    func testSwimmingPaceCalculator_whenCalculatingPace_for1500m_minPer100m_thenReturnsExpectedPace() throws {
        // Arrange: 1500 m in 18:30 (1110 s) -> pace per 100m = 1110 / 15 = 74 s/100m
        let duration = TimeInterval(1110)
        let distance = 1500.0
        let expectedPace = 74.0

        // Act
        let pace = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPer100m)

        // Assert
        XCTAssertNotNil(pace)
        XCTAssertEqual(pace!, expectedPace, accuracy: accuracy)
    }

    func testSwimmingPaceCalculator_whenCalculatingPace_for100yds_minPer100yds_thenReturnsExpectedPace() throws {
        // Arrange: 150 yd = 137.16 m in 75 s -> pace per 100yd = 50 s/100yd
        let duration = TimeInterval(75)
        let distance = 150.0 * metersInYard
        let expectedPace = 50.0

        // Act
        let pace = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPer100yds)

        // Assert
        XCTAssertNotNil(pace)
        XCTAssertEqual(pace!, expectedPace, accuracy: accuracy)
    }

    func testSwimmingPaceCalculator_whenCalculatingPace_withVerySmallDistance_realisticSprint_thenReturnsExpectedPace() throws {
        // Arrange: 25 m in 20 s -> pace per 100m = 80 s/100m
        let duration = TimeInterval(20)
        let distance = 25.0
        let expectedPace100m = 80.0
        let expectedPace100yds = (20.0 / (25.0 / metersInYard)) * 100.0

        // Act
        let pace100m = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPer100m)
        let pace100yd = sut.calculatePace(duration: duration, distance: distance, paceUnit: .minPer100yds)

        // Assert
        XCTAssertNotNil(pace100m)
        XCTAssertEqual(pace100m!, expectedPace100m, accuracy: accuracy)

        XCTAssertNotNil(pace100yd)
        XCTAssertEqual(pace100yd!, expectedPace100yds, accuracy: accuracy)
    }

    func testSwimmingPaceCalculator_whenCalculatingPace_withZeroOrNegativeInputs_thenReturnsNil() {
        // Arrange
        let zeroDuration = TimeInterval(0)
        let zeroDistance = 0.0
        let negativeDuration = TimeInterval(-10)
        let negativeDistance = -50.0

        // Act / Assert
        XCTAssertNil(sut.calculatePace(duration: zeroDuration, distance: 100, paceUnit: .minPer100m))
        XCTAssertNil(sut.calculatePace(duration: 100, distance: zeroDistance, paceUnit: .minPer100m))

        XCTAssertNil(sut.calculatePace(duration: negativeDuration, distance: 100, paceUnit: .minPer100m))
        XCTAssertNil(sut.calculatePace(duration: 100, distance: negativeDistance, paceUnit: .minPer100m))
    }
}

extension SwimmingPaceCalculatorTests {
    // MARK: - calculateTime

    func testSwimmingPaceCalculator_whenCalculatingTime_for1500m_minPer100m_thenReturnsExpectedTime() throws {
        // Arrange: pace = 74 s/100m, distance = 1500 m -> time = 1110 s
        let pace = 74.0
        let distance = 1500.0
        let expectedTime = 1110.0

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPer100m)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testSwimmingPaceCalculator_whenCalculatingTime_for100yds_minPer100yds_thenReturnsExpectedTime() throws {
        // Arrange: pace = 63 s/100yd, distance = 100 yd (91.44 m) -> time = 63 s
        let pace = 63.0
        let distance = 100.0 * metersInYard
        let expectedTime = 63.0

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPer100yds)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testSwimmingPaceCalculator_whenCalculatingTime_for25mSprint_withWholeSecondPace_thenReturnsExpectedTime() throws {
        // Arrange: pace = 80 s/100m, distance = 25 m -> time = 20 s
        let pace = 80.0
        let distance = 25.0
        let expectedTime = 20.0

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPer100m)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, expectedTime, accuracy: accuracy)
    }

    func testSwimmingPaceCalculator_whenCalculatingTime_preservesFractionalSeconds() throws {
        // Arrange: pace = 75 s/100m, distance = 1234 m -> time = 925.5 s (fractional)
        let pace = 75.0
        let distance = 1234.0

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPer100m)

        // Assert
        XCTAssertNotNil(time)
        let fractionalPart = time! - floor(time!)
        XCTAssertGreaterThan(fractionalPart, 0.0, "Expected fractional seconds to be preserved (not truncated).")
    }

    func testSwimmingPaceCalculator_whenCalculatingTime_withZeroPace_thenReturnsZero() {
        // Arrange: zero pace -> zero time
        let pace = 0.0
        let distance = 400.0

        // Act
        let time = sut.calculateTime(pace: pace, distance: distance, paceUnit: .minPer100m)

        // Assert
        XCTAssertNotNil(time)
        XCTAssertEqual(time!, 0.0, accuracy: accuracy)
    }
}

extension SwimmingPaceCalculatorTests {
    // MARK: - formatPace

    func testSwimmingPaceCalculator_whenFormattingPace_minPer100m_thenReturnsExpectedString() {
        // Arrange: 74 s -> "1:14 min/100m"
        let paceInSeconds = 74.0
        let expected = "1:14 min/100m"

        // Act
        let formatted = sut.formatPace(paceInSeconds, with: .minPer100m)

        // Assert
        XCTAssertEqual(formatted, expected)
    }

    func testSwimmingPaceCalculator_whenFormattingPace_minPer100yds_thenReturnsExpectedString() {
        // Arrange: 63 s -> "1:03 min/100yd"
        let paceInSeconds = 63.0
        let expected = "1:03 min/100yd"

        // Act
        let formatted = sut.formatPace(paceInSeconds, with: .minPer100yds)

        // Assert
        XCTAssertEqual(formatted, expected)
    }
}
