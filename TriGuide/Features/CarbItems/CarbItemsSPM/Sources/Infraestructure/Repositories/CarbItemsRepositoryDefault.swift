//
// TriGuide 2025
//

actor CarbItemsRepositoryDefault: CarbItemsRepository {
    let dataSource: CarbItemsDataSource

    init(dataSource: CarbItemsDataSource) {
        self.dataSource = dataSource
    }

    func getCarbItems() async throws -> [CarbItem] {
        let carbItemDtos = try await dataSource.fetchCarbItems()
        return carbItemDtos.map { $0.toDomain() }
    }
}
