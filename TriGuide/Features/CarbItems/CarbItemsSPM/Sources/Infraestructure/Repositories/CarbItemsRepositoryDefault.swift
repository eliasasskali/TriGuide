//
// TriGuide 2025
//

actor CarbItemsRepositoryDefault: CarbItemsRepository {
    let remoteDataSource: CarbItemsDataSource
    let localDataSource: LocalCarbItemsDataSource

    private var items: [CarbItem] = []
    private var hasLoadedOnce = false

    init(
        remoteDataSource: CarbItemsDataSource,
        localDataSource: LocalCarbItemsDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func getCarbItems(forceRefresh: Bool) async throws -> [CarbItem] {
        if hasLoadedOnce && !forceRefresh {
            return items
        }

        if !hasLoadedOnce || forceRefresh {
            do {
                let remoteDtos = try await remoteDataSource.fetchCarbItems()
                items = remoteDtos.map { $0.toDomain() }
                try await localDataSource.saveCarbItems(remoteDtos)
                hasLoadedOnce = true
                return items
            } catch {
                let localDtos = try await localDataSource.loadCarbItems()
                if !localDtos.isEmpty {
                    items = localDtos.map { $0.toDomain() }
                    hasLoadedOnce = true
                    return items
                }
                throw error
            }
        }

        let localDtos = try await localDataSource.loadCarbItems()
        items = localDtos.map { $0.toDomain() }
        hasLoadedOnce = true
        return items
    }
}
