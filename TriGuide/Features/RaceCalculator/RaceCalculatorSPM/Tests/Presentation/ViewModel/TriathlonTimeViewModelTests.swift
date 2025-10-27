//
// TriGuide 2025
//

import XCTest
@testable import RaceCalculatorSPM

final class TriathlonTimeViewModelTests: XCTestCase {

    func testTriathlonTimeViewModel_whenUpdateSwimTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = TriathlonTimeViewModel()
        let expected = 100.0.formattedAsHourMinSec

        // Act
        sut.swimTime = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateT1Time_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = TriathlonTimeViewModel()
        let expected = 200.0.formattedAsHourMinSec

        // Act
        sut.swimTime = 100.0
        sut.t1Time = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateCyclingTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = TriathlonTimeViewModel()
        let expected = 300.0.formattedAsHourMinSec

        // Act
        sut.swimTime = 100.0
        sut.t1Time = 100.0
        sut.cyclingTime = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateT2Time_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = TriathlonTimeViewModel()
        let expected = 400.0.formattedAsHourMinSec

        // Act
        sut.swimTime = 100.0
        sut.t1Time = 100.0
        sut.cyclingTime = 100.0
        sut.t2Time = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateRunningTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = TriathlonTimeViewModel()
        let expected = 500.0.formattedAsHourMinSec

        // Act
        sut.swimTime = 100.0
        sut.t1Time = 100.0
        sut.cyclingTime = 100.0
        sut.t2Time = 100.0
        sut.runningTime = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }
}
