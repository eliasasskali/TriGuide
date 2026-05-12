//
// TriGuide 2025
//

import Foundation

public actor LocalStorage<T: Codable> {
    // MARK: - Dependencies

    private let directory: URL
    private let fileName: String

    // MARK: - Initializer

    public init(fileName: String, directory: URL? = nil) throws {
        if let dir = directory {
            self.directory = dir
        } else if let defaultDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.directory = defaultDir
        } else {
            throw LocalStorageError.unableToLocateDirectory
        }
        self.fileName = fileName
    }

    // MARK: - Computed properties

    private var fileURL: URL {
        directory.appendingPathComponent("\(fileName).json")
    }

    // MARK: - Public Methods

    public func load() async throws -> T {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw LocalStorageError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw LocalStorageError.decodeFailed(decodingError)
        } catch {
            throw LocalStorageError.loadFailed(error)
        }
    }

    public func save(_ value: T) async throws {
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw LocalStorageError.saveFailed(error)
        }
    }

    public func remove() async throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw LocalStorageError.deleteFailed(error)
        }
    }
}
