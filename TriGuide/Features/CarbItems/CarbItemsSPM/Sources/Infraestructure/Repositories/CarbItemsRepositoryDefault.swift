//
// TriGuide 2025
//

import Foundation

actor CarbItemsRepositoryDefault: CarbItemsRepository {
    enum RepositoryError: Error, Equatable {
        case remoteAndCacheFailed(remoteError: Error, cacheError: Error?)
        case duplicateUserItem

        static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {
            switch (lhs, rhs) {
            case (.duplicateUserItem, .duplicateUserItem),
                 (.remoteAndCacheFailed, .remoteAndCacheFailed):
                return true
            default:
                return false
            }
        }
    }

    private let remoteItemsDataSource: RemoteCarbItemsDataSource
    private let cachedItemsDataSource: CachedCarbItemsDataSource
    private let userItemsDataSource: UserCarbItemsDataSource
    private let timeToRefresh: TimeInterval

    private var items: [CarbItem] = []
    private var lastLoadedAt: Date?
    private var userItems: [CarbItem] = []
    private var hasLoadedOnce = false

    init(
        remoteCarbItemsDataSource: RemoteCarbItemsDataSource,
        cachedCarbItemsDataSource: CachedCarbItemsDataSource,
        userCarbItemsDataSource: UserCarbItemsDataSource,
        timeToRefresh: TimeInterval = 600
    ) {
        self.remoteItemsDataSource = remoteCarbItemsDataSource
        self.cachedItemsDataSource = cachedCarbItemsDataSource
        self.userItemsDataSource = userCarbItemsDataSource
        self.timeToRefresh = timeToRefresh
    }

    // MARK: - Remote/Cached Carb Items

    func getCarbItems(forceRefresh: Bool = false) async throws -> [CarbItem] {
        if hasLoadedOnce && !forceRefresh {
            if let lastLoadedAt, Date().timeIntervalSince(lastLoadedAt) < timeToRefresh {
                return items
            }
        }

        do {
            let remoteDtos = try await remoteItemsDataSource.fetchCarbItems()
            let remoteItems = remoteDtos.map { $0.toDomain() }

            if remoteItems.isEmpty {
                do {
                    let localDtos = try await cachedItemsDataSource.loadCarbItems()
                    if !localDtos.isEmpty {
                        let localItems = localDtos.map { $0.toDomain() }
                        items = localItems
                        lastLoadedAt = Date()
                        hasLoadedOnce = true
                        return items
                    }
                } catch {
                    // In this case, we continue and return the empty remote
                }
            }

            items = remoteItems
            lastLoadedAt = Date()
            hasLoadedOnce = true

            do {
                try await cachedItemsDataSource.saveCarbItems(remoteDtos)
            } catch {
                // It failed saving to cache, but we can continue
                // TODO: Log error saving to cache
            }

            return items
        } catch {
            let remoteError = error
            do {
                let localDtos = try await cachedItemsDataSource.loadCarbItems()
                guard !localDtos.isEmpty else {
                    throw RepositoryError.remoteAndCacheFailed(remoteError: remoteError, cacheError: nil)
                }
                let localItems = localDtos.map { $0.toDomain() }
                items = localItems
                lastLoadedAt = Date()
                hasLoadedOnce = true
                return items
            } catch {
                throw RepositoryError.remoteAndCacheFailed(remoteError: remoteError, cacheError: error)
            }
        }
    }

    // MARK: - User Carb Items

    func getUserCarbItems(forceRefresh: Bool = false) async throws -> [CarbItem] {
        if !userItems.isEmpty && !forceRefresh {
            return userItems
        }
        userItems = try await userItemsDataSource.getCarbItems()
        return userItems
    }

    func addUserCarbItem(_ item: CarbItem) async throws {
        if userItems.isEmpty {
            userItems = try await userItemsDataSource.getCarbItems()
        }

        if userItems.contains(where: { $0.id == item.id }) {
            throw RepositoryError.duplicateUserItem
        }

        try await userItemsDataSource.addCarbItem(item)
        userItems.append(item)
    }

    func removeUserCarbItem(with id: String) async throws {
        try await userItemsDataSource.deleteCarbItem(id: id)
        userItems.removeAll { $0.id == id }
    }
}
