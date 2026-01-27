//
// TriGuide 2025
//

import Combine
@testable import RaceCalculatorSPM
import TriGuideDomain
import XCTest

@MainActor
final class PaceCalculatorViewModelTests: XCTestCase {
    let paceCalculatorPace: Double = 321.0
    let paceCalculatorDuration: Double = 321.0
    let paceCalculatorDistance: Double = 321.0
    let paceCalculatorFormattedPace: String = "3:21 min/km"

    func givenSut(
        pace: Double? = nil,
        speed: Double? = nil,
        duration: Double? = nil,
        distance: Double? = nil,
        paceUnit: SpeedUnit = .minPerKm
    ) -> PaceCalculatorViewModel {
        let paceCalculatorMock = PaceCalculatorMock(
            pace: paceCalculatorPace,
            time: paceCalculatorDuration,
            distance: paceCalculatorDistance,
            formattedPace: paceCalculatorFormattedPace
        )
        return PaceCalculatorViewModel(
            paceCalculator: paceCalculatorMock,
            distance: distance,
            duration: duration,
            pace: pace,
            speed: speed,
            paceUnit: paceUnit
        )
    }
}

extension PaceCalculatorViewModelTests {
    // MARK: - Updating without required fields

    func testPaceCalculatorViewModel_whenUpdatePace_withoutDurationNorDistance_thenDoesntUpdateDurationNorDistance() async throws {
        // Arrange
        let sut = givenSut()
        var cancellables = Set<AnyCancellable>()

        let updateDurationExpectation = XCTestExpectation(description: "Duration should not be updated")
        let updateDistanceExpectation = XCTestExpectation(description: "Distance should not be updated")
        updateDurationExpectation.isInverted = true
        updateDistanceExpectation.isInverted = true

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.pace = 100.0

        // Assert
        await fulfillment(of: [updateDurationExpectation, updateDistanceExpectation], timeout: 1)
    }

    func testPaceCalculatorViewModel_whenUpdateSpeed_withoutDurationNorDistance_thenDoesntUpdateDurationNorDistance() async throws {
        // Arrange
        let sut = givenSut(paceUnit: .kmPerHour)
        var cancellables = Set<AnyCancellable>()

        let updateDurationExpectation = XCTestExpectation(description: "Duration should not be updated")
        let updateDistanceExpectation = XCTestExpectation(description: "Distance should not be updated")
        updateDurationExpectation.isInverted = true
        updateDistanceExpectation.isInverted = true

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.speed = 100.0

        // Assert
        await fulfillment(of: [updateDurationExpectation, updateDistanceExpectation], timeout: 1)
    }

    func testPaceCalculatorViewModel_whenUpdateDuration_withoutPaceNorDistance_thenDoesntUpdatePaceNorDistance() async throws {
        // Arrange
        let sut = givenSut()
        var cancellables = Set<AnyCancellable>()

        let updatePaceExpectation = XCTestExpectation(description: "Pace should not be updated")
        let updateDistanceExpectation = XCTestExpectation(description: "Distance should not be updated")
        updatePaceExpectation.isInverted = true
        updateDistanceExpectation.isInverted = true

        sut.$pace
            .dropFirst()
            .sink { _ in
                updatePaceExpectation.fulfill()
            }
            .store(in: &cancellables)

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.duration = 100.0

        // Assert
        await fulfillment(of: [updatePaceExpectation, updateDistanceExpectation], timeout: 1)
    }

    func testPaceCalculatorViewModel_whenUpdateDistance_withoutPaceNorDuration_thenDoesntUpdatePaceOrDuration() async throws {
        // Arrange
        let sut = givenSut()
        var cancellables = Set<AnyCancellable>()

        let updatePaceExpectation = XCTestExpectation(description: "Pace should not be updated")
        let updateDurationExpectation = XCTestExpectation(description: "Duration should not be updated")
        updatePaceExpectation.isInverted = true
        updateDurationExpectation.isInverted = true

        sut.$pace
            .dropFirst()
            .sink { _ in
                updatePaceExpectation.fulfill()
            }
            .store(in: &cancellables)

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.distance = 100.0

        // Assert
        await fulfillment(of: [updatePaceExpectation, updateDurationExpectation], timeout: 1)
    }

    func testPaceCalculatorViewModel_whenChangingPaceUnit_withoutDurationDistanceNorPace_thenDoesntUpdateAnything() async throws {
        // Arrange
        let sut = givenSut(paceUnit: .minPerKm)
        var cancellables = Set<AnyCancellable>()

        let updatePaceExpectation = XCTestExpectation(description: "Pace should update")
        let updateDurationExpectation = XCTestExpectation(description: "Duration should not be updated")
        let updateDistanceExpectation = XCTestExpectation(description: "Distance should not be updated")
        updatePaceExpectation.isInverted = true
        updateDurationExpectation.isInverted = true
        updateDistanceExpectation.isInverted = true

        sut.$pace
            .dropFirst()
            .sink { _ in
                updatePaceExpectation.fulfill()
            }
            .store(in: &cancellables)

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.paceUnit = .minPerMile

        // Assert
        await fulfillment(of: [updatePaceExpectation, updateDurationExpectation, updateDistanceExpectation], timeout: 1)
    }
}

extension PaceCalculatorViewModelTests {
    // MARK: - Updating pace with required fields

    func testPaceCalculatorViewModel_whenUpdatePace_withDuration_thenDoesUpdateDistance() async throws {
        // Arrange
        let sut = givenSut(duration: 100.0)
        var cancellables = Set<AnyCancellable>()

        let updateDistanceExpectation = XCTestExpectation(description: "Distance should update")

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.pace = 100.0

        // Assert
        await fulfillment(of: [updateDistanceExpectation], timeout: 1)
        XCTAssertEqual(sut.distance, paceCalculatorDistance)
    }

    func testPaceCalculatorViewModel_whenUpdatePace_withDistance_thenDoesUpdateDuration() async throws {
        // Arrange
        let sut = givenSut(distance: 100.0)
        var cancellables = Set<AnyCancellable>()

        let updateDurationExpectation = XCTestExpectation(description: "Duration should update")

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.pace = 100.0

        // Assert
        await fulfillment(of: [updateDurationExpectation], timeout: 1)
        XCTAssertEqual(sut.duration, paceCalculatorDuration)
    }

    // MARK: - Updating speed with required fields

    func testPaceCalculatorViewModel_whenUpdateSpeed_withDuration_thenDoesUpdateDistance() async throws {
        // Arrange
        let sut = givenSut(duration: 100.0, paceUnit: .kmPerHour)
        var cancellables = Set<AnyCancellable>()

        let updateDistanceExpectation = XCTestExpectation(description: "Distance should update")

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.speed = 100.0

        // Assert
        await fulfillment(of: [updateDistanceExpectation], timeout: 1)
        XCTAssertEqual(sut.distance, paceCalculatorDistance)
    }

    func testPaceCalculatorViewModel_whenUpdateSpeed_withDistance_thenDoesUpdateDuration() async throws {
        // Arrange
        let sut = givenSut(distance: 100.0, paceUnit: .kmPerHour)
        var cancellables = Set<AnyCancellable>()

        let updateDurationExpectation = XCTestExpectation(description: "Duration should update")

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.speed = 100.0

        // Assert
        await fulfillment(of: [updateDurationExpectation], timeout: 1)
        XCTAssertEqual(sut.duration, paceCalculatorDuration)
    }

    // MARK: - Updating duration with required fields

    func testPaceCalculatorViewModel_whenUpdateDuration_withPace_thenDoesUpdateDistance() async throws {
        // Arrange
        let sut = givenSut(pace: 100.0)
        var cancellables = Set<AnyCancellable>()

        let updateDistanceExpectation = XCTestExpectation(description: "Distance should update")

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.duration = 100.0

        // Assert
        await fulfillment(of: [updateDistanceExpectation], timeout: 1)
        XCTAssertEqual(sut.distance, paceCalculatorDistance)
    }

    func testPaceCalculatorViewModel_whenUpdateDuration_withSpeed_thenDoesUpdateDistance() async throws {
        // Arrange
        let sut = givenSut(speed: 100.0, paceUnit: .kmPerHour)
        var cancellables = Set<AnyCancellable>()

        let updateDistanceExpectation = XCTestExpectation(description: "Distance should update")

        sut.$distance
            .dropFirst()
            .sink { _ in
                updateDistanceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.duration = 100.0

        // Assert
        await fulfillment(of: [updateDistanceExpectation], timeout: 1)
        XCTAssertEqual(sut.distance, paceCalculatorDistance)
    }

    func testPaceCalculatorViewModel_whenUpdateDuration_withDistance_thenDoesUpdatePace() async throws {
        // Arrange
        let sut = givenSut(distance: 100.0)
        var cancellables = Set<AnyCancellable>()

        let updatePaceExpectation = XCTestExpectation(description: "Pace should update")

        sut.$pace
            .dropFirst()
            .sink { _ in
                updatePaceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.duration = 100.0

        // Assert
        await fulfillment(of: [updatePaceExpectation], timeout: 1)
        XCTAssertEqual(sut.pace, paceCalculatorPace)
    }

    // MARK: - Updating distance with required fields

    func testPaceCalculatorViewModel_whenUpdateDistance_withPace_thenDoesUpdateDuration() async throws {
        // Arrange
        let sut = givenSut(pace: 100.0)
        var cancellables = Set<AnyCancellable>()

        let updateDurationExpectation = XCTestExpectation(description: "Duration should update")

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.distance = 100.0

        // Assert
        await fulfillment(of: [updateDurationExpectation], timeout: 1)
        XCTAssertEqual(sut.duration, paceCalculatorDuration)
    }

    func testPaceCalculatorViewModel_whenUpdateDistance_withSpeed_thenDoesUpdateDuration() async throws {
        // Arrange
        let sut = givenSut(speed: 100.0, paceUnit: .kmPerHour)
        var cancellables = Set<AnyCancellable>()

        let updateDurationExpectation = XCTestExpectation(description: "Duration should update")

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.distance = 100.0

        // Assert
        await fulfillment(of: [updateDurationExpectation], timeout: 1)
        XCTAssertEqual(sut.duration, paceCalculatorDuration)
    }

    func testPaceCalculatorViewModel_whenUpdateDistance_withDuration_thenDoesUpdatePace() async throws {
        // Arrange
        let sut = givenSut(duration: 100.0)
        var cancellables = Set<AnyCancellable>()

        let updatePaceExpectation = XCTestExpectation(description: "Pace should update")

        sut.$pace
            .dropFirst()
            .sink { _ in
                updatePaceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.distance = 100.0

        // Assert
        await fulfillment(of: [updatePaceExpectation], timeout: 1)
        XCTAssertEqual(sut.pace, paceCalculatorPace)
    }

    // MARK: - Changing pace unit

    func testPaceCalculatorViewModel_whenChangingPaceUnit_withDurationDistanceAndPace_thenUpdatesPace() async throws {
        // Arrange
        let sut = givenSut(pace: 100.0, duration: 100.0, distance: 100.0, paceUnit: .minPerKm)
        var cancellables = Set<AnyCancellable>()

        let updatePaceExpectation = XCTestExpectation(description: "Pace should update")

        sut.$pace
            .dropFirst()
            .sink { _ in
                updatePaceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.paceUnit = .minPerMile

        // Assert
        await fulfillment(of: [updatePaceExpectation], timeout: 1)
        XCTAssertEqual(sut.pace, paceCalculatorPace)
    }

    // MARK: - Changind distance unit

    func testPaceCalculatorViewModel_whenChangingDistanceUnit_withDurationDistanceAndPace_thenUpdatesDuration() async throws {
        // Arrange
        let sut = givenSut(pace: 100.0, duration: 100.0, distance: 100.0, paceUnit: .minPerKm)
        var cancellables = Set<AnyCancellable>()

        let updateDurationExpectation = XCTestExpectation(description: "Duration should update")
        let updatePaceExpectation = XCTestExpectation(description: "Pace should not update")
        updatePaceExpectation.isInverted = true

        sut.$duration
            .dropFirst()
            .sink { _ in
                updateDurationExpectation.fulfill()
            }
            .store(in: &cancellables)

        sut.$pace
            .dropFirst()
            .sink { _ in
                updatePaceExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        sut.distanceUnit = .miles

        // Assert
        await fulfillment(of: [updateDurationExpectation, updatePaceExpectation], timeout: 1)
        XCTAssertEqual(sut.duration, paceCalculatorDuration)
    }
}
