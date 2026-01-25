//
// TriGuide 2025
//

import Foundation
import Testing
import TriGuideDomain
@testable import CarbItemsSPM

@Suite
struct CarbItemsRepositoryDefaultTests {}

// MARK: - Private methods

private extension CarbItemsRepositoryDefaultTests {
    func givenSut(
        remote: RemoteCarbItemsDataSourceMock = RemoteCarbItemsDataSourceMock(),
        cache: CachedCarbItemsDataSourceMock = CachedCarbItemsDataSourceMock(),
        favoriteDataSource: FavoriteCarbItemsDataSourceMock = FavoriteCarbItemsDataSourceMock(),
        userDataSource: UserCarbItemsDataSourceMock = UserCarbItemsDataSourceMock()
    ) -> CarbItemsRepositoryDefault {
        CarbItemsRepositoryDefault(
            remoteCarbItemsDataSource: remote,
            cachedCarbItemsDataSource: cache,
            favoriteCarbItemsDataSource: favoriteDataSource,
            userCarbItemsDataSource: userDataSource
        )
    }

    func dto(id: String, name: String, carbs: Double = 25, type: CarbType = .gel) -> CarbItemDto {
        return CarbItemDto(id: id, name: name, gramsOfCarbs: carbs, type: type)
    }

    func domainItem(id: String, name: String, carbs: Double = 25, type: CarbType = .gel) -> CarbItem {
        return CarbItem(id: id, name: name, gramsOfCarbs: carbs, type: type)
    }
}

extension CarbItemsRepositoryDefaultTests {
    // MARK: - Remote & Cache

    @Test("Loads from remote and saves items in cache.")
    func test_whenGetCarbItems_thenlLoadsFromRemoteAndCachesIt() async throws {
        // Arrange
        let remote = RemoteCarbItemsDataSourceMock(dtos: [dto(id: "1", name: "Gel")])
        let cache = CachedCarbItemsDataSourceMock()
        let sut = givenSut(remote: remote, cache: cache)

        // Act
        let items = try await sut.getCarbItems()

        // Assert
        #expect(items.count == 1)
        #expect(await cache.didSave == true)
        #expect(items.first?.id == "1")
    }

    @Test("When remote fails it loads from cache.")
    func test_whenGetCarbItemsAndRemoteFails_thenlLoadsFromCache() async throws {
        // Arrange
        let remote = RemoteCarbItemsDataSourceMock(shouldThrow: true)
        let cache = CachedCarbItemsDataSourceMock(
            dtos: [dto(id: "2", name: "Bar", carbs: 30)]
        )
        let sut = givenSut(remote: remote, cache: cache)

        // Act
        let items = try await sut.getCarbItems()

        // Assert
        #expect(items.count == 1)
        #expect(items.first?.id == "2")
    }

    @Test("Throws when both remote and cache fail.")
    func test_whenGetCarbItemsAndBothRemoteAndCacheFail_thenItThrows() async throws {
        // Arrange
        let remote = RemoteCarbItemsDataSourceMock(shouldThrow: true)
        let cache = CachedCarbItemsDataSourceMock(shouldThrowOnLoad: true)
        let sut = givenSut(remote: remote, cache: cache)

        // Act / Assert
        do {
            _ = try await sut.getCarbItems()
            preconditionFailure("Should have thrown an error")
        } catch {
            if let repoError = error as? CarbItemsRepositoryDefault.RepositoryError {
                switch repoError {
                case .remoteAndCacheFailed:
                    #expect(true)
                default:
                    preconditionFailure("Should have thrown a remoteAndCacheFailed error")
                }
            } else {
                preconditionFailure("Should have thrown a RepositoryError error")
            }
        }
    }

    // MARK: - User Items

    @Test("Adds a user carb item successfully.")
    func test_whenAddUserCarbItem_thenItAddCarbItemSuccessfully() async throws {
        // Arrange
        let item = domainItem(id: "u1", name: "Banana", carbs: 27)
        let sut = givenSut()

        // Act
        try await sut.addUserCarbItem(item)
        let loaded = try await sut.getUserCarbItems()

        // Assert
        #expect(loaded.count == 1)
        #expect(loaded.first?.id == "u1")
    }

    @Test("Adding a duplicate item will throw an error.")
    func test_whenAddDuplicateUserCarbItem_thenItThrowsDuplicateError() async throws {
        // Arrange
        let item = domainItem(id: "u1", name: "Banana", carbs: 27)
        let sut = givenSut()
        try await sut.addUserCarbItem(item)

        // Act / Assert
        do {
            try await sut.addUserCarbItem(item)
            preconditionFailure("Should have thrown an error")
        } catch let error as CarbItemsRepositoryDefault.RepositoryError {
            #expect(error == .duplicateUserItem)
        } catch {
            preconditionFailure("Should have thrown a duplicateUserItem error")
        }
    }

    @Test("Removes a user carb item successfully.")
    func removeUserCarbItem_removesCorrectly() async throws {
        // Arrange
        let item = domainItem(id: "u1", name: "Banana", carbs: 27)
        let sut = givenSut()
        try await sut.addUserCarbItem(item)

        // Act
        try await sut.removeUserCarbItem(with: item.id)
        let items = try await sut.getUserCarbItems()

        // Assert
        #expect(items.isEmpty)
    }

    // MARK: - Favorite Items

    @Test("Toggles favorite status correctly.")
    func test_whenToggleFavoriteStatus_thenItTogglesCorrectly() async throws {
        // Arrange
        let item = dto(id: "f1", name: "Gel")
        let remote = RemoteCarbItemsDataSourceMock(dtos: [item])
        let sut = givenSut(remote: remote)

        // Act
        _ = try await sut.getCarbItems()
        await sut.toggleFavorite(with: item.id)
        var items = try await sut.getCarbItems()

        // Assert
        #expect(items.count == 1)
        #expect(items.first?.isFavorite == true)

        // Act - toggle again to remove from favorites
        await sut.toggleFavorite(with: item.id)
        items = try await sut.getCarbItems()

        // Assert
        #expect(items.first?.isFavorite == false)
    }

}
