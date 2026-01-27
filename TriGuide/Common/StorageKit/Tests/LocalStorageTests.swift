//
// TriGuide 2025
//

import Foundation
@testable import StorageKit
import Testing

struct LocalStorageTests {
    private struct MockItem: Codable, Equatable {
        let id: Int
        let name: String
    }

    @Test("Saving and loading objects should work correctly")
    func saveAndLoad() async throws {
        // Arrange
        let tempDir = FileManager.default.temporaryDirectory
        let sut = try LocalStorage<[MockItem]>(fileName: "test_items", directory: tempDir)
        let items = [
            MockItem(id: 1, name: "Gel"),
            MockItem(id: 2, name: "Drink"),
        ]

        // Act
        try await sut.save(items)
        let loaded = try await sut.load()

        // Assert
        #expect(loaded == items)
    }

    @Test("Loading non-existent file should throw fileNotFound")
    func loadNonExistent() async throws {
        // Arrange
        let tempDir = FileManager.default.temporaryDirectory
        let sut = try LocalStorage<[MockItem]>(fileName: "missing_items", directory: tempDir)

        // Act & Assert
        await #expect(throws: LocalStorageError.fileNotFound) {
            _ = try await sut.load()
        }
    }

    @Test("Removing file deletes it successfully")
    func removeFile() async throws {
        // Arrange
        let tempDir = FileManager.default.temporaryDirectory
        let sut = try LocalStorage<[MockItem]>(fileName: "remove_test", directory: tempDir)
        let items = [MockItem(id: 1, name: "Gel")]

        // Act: Save - Ensure it exists - Remove
        try await sut.save(items)
        _ = try await sut.load()
        try await sut.remove()

        // Assert: Now loading should throw fileNotFound
        await #expect(throws: LocalStorageError.fileNotFound) {
            _ = try await sut.load()
        }
    }

    @Test("Handles invalid JSON gracefully")
    func invalidJSON() async throws {
        // Arrange
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "invalid_json"
        let fileURL = tempDir.appendingPathComponent("\(fileName).json")

        // Act/Assert: Write invalid data manually
        try "not json".write(to: fileURL, atomically: true, encoding: .utf8)
        let sut = try LocalStorage<[MockItem]>(fileName: fileName, directory: tempDir)

        do {
            _ = try await sut.load()
            Issue.record("Expected LocalStorageError.decodeFailed, but no error was thrown.")
        } catch let error as LocalStorageError {
            #expect(error.isSameCase(as: .decodeFailed(NSError(domain: "", code: 0))))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Helpers

private extension LocalStorageError {
    func isSameCase(as other: LocalStorageError) -> Bool {
        switch (self, other) {
        case (.unableToLocateDirectory, .unableToLocateDirectory),
             (.fileNotFound, .fileNotFound),
             (.saveFailed, .saveFailed),
             (.loadFailed, .loadFailed),
             (.decodeFailed, .decodeFailed),
             (.deleteFailed, .deleteFailed):
            return true
        default:
            return false
        }
    }
}
