//
// TriGuide 2025
//

import Foundation
@testable import FormKit
import Localization
import Testing

enum TestFailure: Error, CustomStringConvertible {
    case failed(String)
    var description: String {
        switch self {
        case .failed(let message): return message
        }
    }
}

// MARK: - FormViewModelTests

struct FormViewModelTests {
    @Test("Required validation fails for an empty required text field")
    func requiredValidationFails() async throws {
        // Arrange
        let field = FieldDescriptor(
            id: "name",
            label: "Name",
            type: .text,
            required: true
        )
        let sut = await givenSut(fields: [field])

        // Act
        let valid = await sut.validate()

        // Assert
        if valid {
            throw TestFailure.failed("Expected validation to fail for empty required field")
        }
        let error = await sut.errors["name"]
        if error != Localizables.FormErrors.requiredField {
            throw TestFailure.failed("Expected error '\(Localizables.FormErrors.requiredField)', got: '\(error ?? "nil")'")
        }
    }

    @Test("Integer field rejects non-digit characters")
    func integerFieldRejectsInvalidChars() async throws {
        // Arrange
        let field = FieldDescriptor(
            id: "age",
            label: "Age",
            type: .integer,
            required: false
        )
        let sut = await givenSut(fields: [field])

        // Act
        await sut.updateValue("age", value: "12a")
        let valid = await sut.validate()

        // Assert
        if valid {
            throw TestFailure.failed("Expected integer validation to fail for '12a'")
        }
        let error = await sut.errors["age"]
        if error != Localizables.FormErrors.invalidNumber {
            throw TestFailure.failed("Expected '\(Localizables.FormErrors.invalidNumber)', got '\(error ?? "nil")'")
        }
    }

    @Test("Decimal field obeys min/max range")
    func decimalRangeValidation() async throws {
        // Arrange
        let field = FieldDescriptor(
            id: "grams",
            label: "Grams",
            type: .decimal,
            required: true,
            min: 1,
            max: 100
        )
        let sut = await givenSut(fields: [field])

        // Act & Assert - too small
        await sut.updateValue("grams", value: "0.5")
        var valid = await sut.validate()
        if valid {
            throw TestFailure.failed("Expected validation to fail for value 0.5 (< min)")
        }
        var err = await sut.errors["grams"]
        if err != Localizables.FormErrors.betweenMinAndMax(min: 1, max: 100) {
            throw TestFailure.failed("Expected '\(Localizables.FormErrors.betweenMinAndMax(min: 1, max: 100))', got '\(err ?? "nil")'")
        }

        // Act & Assert - in range
        await sut.updateValue("grams", value: "50")
        valid = await sut.validate()
        if !valid {
            throw TestFailure.failed("Expected validation to pass for value 50")
        }
        err = await sut.errors["grams"]
        if err != nil {
            throw TestFailure.failed("Expected error to be cleared after valid input, found '\(err!)'")
        }
    }

    @Test("buildResult converts typed values correctly")
    func buildResultSuccess() async throws {
        // Arrange
        let f1 = FieldDescriptor(id: "name", label: "Name", type: .text)
        let f2 = FieldDescriptor(id: "caffeine", label: "Caffeine", type: .integer)
        let f3 = FieldDescriptor(id: "vol", label: "Volume", type: .decimal)

        let sut = await givenSut(fields: [f1, f2, f3])

        // Act
        await sut.updateValue("name", value: "Gel A")
        await sut.updateValue("caffeine", value: "80")
        await sut.updateValue("vol", value: "200.5")

        let result = await sut.buildResult()

        // Assert
        if case .string(let s) = result["name"] {
            if s != "Gel A" {
                throw TestFailure.failed("Expected name 'Gel A', got '\(s)'")
            }
        } else {
            throw TestFailure.failed("Expected name to be FormValue.string")
        }

        if case .int(let i) = result["caffeine"] {
            if i != 80 {
                throw TestFailure.failed("Expected caffeine 80, got \(i)")
            }
        } else {
            throw TestFailure.failed("Expected caffeine to be FormValue.int")
        }

        if case .double(let d) = result["vol"] {
            if d != 200.5 {
                throw TestFailure.failed("Expected vol 200.5, got \(d)")
            }
        } else {
            throw TestFailure.failed("Expected vol to be FormValue.double")
        }
    }
}

private extension FormViewModelTests {
    func givenSut(
        fields: [FieldDescriptor] = [],
        initial: FormResult? = nil
    ) async -> FormViewModel {
        await FormViewModel(fields: fields, initial: initial)
    }
}
