//
// TriGuide 2025
//

@testable import RaceCalculatorSPM
import XCTest

final class DuathlonTimeViewModelTests: XCTestCase {
    // Default t1 and t2 are 60 seconds each

    func testTriathlonTimeViewModel_whenUpdateFirstRunTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let defaultTransitions = 120.0 // t1(60) + t2(60)
        let expected = (100.0 + defaultTransitions).formattedAsHourMinSec

        // Act
        sut.firstRunTime = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateT1Time_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let expected = (100.0 + 100.0 + 60.0).formattedAsHourMinSec // firstRun + t1 + default t2

        // Act
        sut.firstRunTime = 100.0
        sut.t1Time = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateCyclingTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let expected = (100.0 + 100.0 + 100.0 + 60.0).formattedAsHourMinSec // firstRun + t1 + cycling + default t2

        // Act
        sut.firstRunTime = 100.0
        sut.t1Time = 100.0
        sut.cyclingTime = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateT2Time_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let expected = 400.0.formattedAsHourMinSec

        // Act
        sut.firstRunTime = 100.0
        sut.t1Time = 100.0
        sut.cyclingTime = 100.0
        sut.t2Time = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateSecondRunTimeTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let expected = 500.0.formattedAsHourMinSec

        // Act
        sut.firstRunTime = 100.0
        sut.t1Time = 100.0
        sut.cyclingTime = 100.0
        sut.t2Time = 100.0
        sut.secondRunTime = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }
}
