//
// TriGuide 2025
//

@testable import RaceCalculatorSPM
import XCTest

final class DuathlonTimeViewModelTests: XCTestCase {
    func testTriathlonTimeViewModel_whenUpdateFirstRunTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let expected = 100.0.formattedAsHourMinSec

        // Act
        sut.firstRunTime = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateT1Time_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let expected = 200.0.formattedAsHourMinSec

        // Act
        sut.firstRunTime = 100.0
        sut.t1Time = 100.0

        // Assert
        XCTAssertEqual(sut.formattedTotalTime, expected)
    }

    func testTriathlonTimeViewModel_whenUpdateCyclingTime_thenTotalTimeIsUpdated() {
        // Arrange
        let sut = DuathlonTimeViewModel()
        let expected = 300.0.formattedAsHourMinSec

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
