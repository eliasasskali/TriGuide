//
// TriGuide 2025
//

import Foundation

public enum LocalStorageError: Error, LocalizedError {
    case unableToLocateDirectory
    case fileNotFound
    case saveFailed(_ error: Error)
    case loadFailed(_ error: Error)
    case decodeFailed(_ error: Error)
    case deleteFailed(_ error: Error)

    public var errorDescription: String? {
        // TODO: Custom error descriptions
        "Local storage error occurred."
    }
}

// MARK: - Equatable

extension LocalStorageError: Equatable {
    public static func == (lhs: LocalStorageError, rhs: LocalStorageError) -> Bool {
        switch (lhs, rhs) {
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
