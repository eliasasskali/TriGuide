//
// TriGuide 2025
//

import XCTest
@testable import RaceCalculatorSPM
import TriGuideDomain

@MainActor
final class SplitsTableViewModelTests: XCTestCase {
    func givenSut() -> SplitsTableViewModel {
        let paceCalculatorMock = PaceCalculatorMock(isTimeMocked: false)
        return SplitsTableViewModel(paceCalculator: paceCalculatorMock)
    }
}

extension SplitsTableViewModelTests {

    func testSplitsTableViewModel_whenUpdateSplitsIsCalledWithParamsToZero_thenEmptySplitsAreUpdated() async throws {
        // Arrange
        let sut = givenSut()
        let expected: [RaceSplit] = []

        // Act-Assert
        sut.updateSplits(splitsDistance: 0, totalDistance: 10.0, pace: 180, paceUnit: .minPerKm)
        assertSplitsEqual(sut.splits, expected)
        sut.updateSplits(splitsDistance: 4, totalDistance: 0, pace: 180, paceUnit: .minPerKm)
        assertSplitsEqual(sut.splits, expected)
        sut.updateSplits(splitsDistance: 4, totalDistance: 10.0, pace: 0, paceUnit: .minPerKm)
        assertSplitsEqual(sut.splits, expected)
    }

    func testSplitsTableViewModel_whenUpdateSplitsIsCalled_thenSplitsAreUpdated() async throws {
        // Arrange
        let sut = givenSut()
        let expected = [
            RaceSplit(distance: 4.0, splitTime: 180*4, cumulativeTime: 180*4),
            RaceSplit(distance: 8.0, splitTime: 180*4, cumulativeTime: 180*8),
            RaceSplit(distance: 10.0, splitTime: 180*2, cumulativeTime: 180*10)
        ]

        // Act
        sut.updateSplits(splitsDistance: 4, totalDistance: 10.0, pace: 180, paceUnit: .minPerKm)

        // Assert
        assertSplitsEqual(sut.splits, expected)
    }

    func testSplitsTableViewModel_whenUpdateSplitsIsCalledWithDecimalDistanceAndKph_thenSplitsAreUpdated() async throws {
        // Arrange: pace is 20km/h -> 180s per km
        let sut = givenSut()
        let expected = [
            RaceSplit(distance: 5.0, splitTime: 180*5, cumulativeTime: 180*5),
            RaceSplit(distance: 10.0, splitTime: 180*5, cumulativeTime: 180*10),
            RaceSplit(distance: 15.0, splitTime: 180*5, cumulativeTime: 180*15),
            RaceSplit(distance: 20.0, splitTime: 180*5, cumulativeTime: 180*20),
            RaceSplit(distance: 21.1, splitTime: 180*1.1, cumulativeTime: 180*21.1),
        ]

        // Act:
        sut.updateSplits(splitsDistance: 5, totalDistance: 21.1, pace: 20, paceUnit: .kmPerHour)

        // Assert
        assertSplitsEqual(sut.splits, expected)
    }

    func testSplitsTableViewModel_whenUpdateSplitsIsCalledWithDecimalDistanceAndMinPer100m_thenSplitsAreUpdated() async throws {
        // Arrange: pace is 1:12 min/100m -> 72s/100m
        let sut = givenSut()
        let expected = [
            RaceSplit(distance: 100.0, splitTime: 72, cumulativeTime: 72),
            RaceSplit(distance: 200.0, splitTime: 72, cumulativeTime: 72*2),
            RaceSplit(distance: 250.0, splitTime: 72/2, cumulativeTime: 72*2.5)
        ]

        // Act:
        sut.updateSplits(splitsDistance: 100, totalDistance: 250, pace: 72, paceUnit: .minPer100m)

        // Assert
        assertSplitsEqual(sut.splits, expected)
    }

    func testSplitsTableViewModel_whenUpdateSplitsWithZeroParameterAndPopulatedSplits_thenSplitsBecomeEmpty() async throws {
        // Arrange:
        let sut = givenSut()
        let splits = [
            RaceSplit(distance: 100.0, splitTime: 72, cumulativeTime: 72),
            RaceSplit(distance: 200.0, splitTime: 72, cumulativeTime: 72*2),
            RaceSplit(distance: 250.0, splitTime: 72/2, cumulativeTime: 72*2.5)
        ]
        sut.splits = splits

        // Act-Assert
        sut.updateSplits(splitsDistance: 0, totalDistance: 250, pace: 72, paceUnit: .minPer100m)
        assertSplitsEqual(sut.splits, [])

        sut.splits = splits
        sut.updateSplits(splitsDistance: 100, totalDistance: 0, pace: 72, paceUnit: .minPer100m)
        assertSplitsEqual(sut.splits, [])

        sut.splits = splits
        sut.updateSplits(splitsDistance: 100, totalDistance: 250, pace: 0, paceUnit: .minPer100m)
        assertSplitsEqual(sut.splits, [])
    }
}

// MARK: - Helpers

private extension SplitsTableViewModelTests {
    func assertSplitsEqual(
        _ actual: [RaceSplit],
        _ expected: [RaceSplit],
        accuracy: Double = 0.01,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(actual.count, expected.count, "split count", file: file, line: line)
        for (i, (a, e)) in zip(actual, expected).enumerated() {
            XCTAssertEqual(a.distance, e.distance, accuracy: accuracy, "distance at index \(i)", file: file, line: line)
            XCTAssertEqual(a.splitTime, e.splitTime, accuracy: accuracy, "splitTime at index \(i)", file: file, line: line)
            XCTAssertEqual(a.cumulativeTime, e.cumulativeTime, accuracy: accuracy, "cumulativeTime at index \(i)", file: file, line: line)
        }
    }
}
