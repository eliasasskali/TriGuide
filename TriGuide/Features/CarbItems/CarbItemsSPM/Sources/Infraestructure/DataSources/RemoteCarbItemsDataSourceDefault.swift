//
// TriGuide 2025
//

import Foundation

struct RemoteCarbItemsDataSourceDefault: RemoteCarbItemsDataSource {
    // MARK: - Constants

    static let carbItemsUrlString = "https://raw.githubusercontent.com/eliasasskali/TriGuideData/master/nutrition/carb_items.json"

    // MARK: - Dependencies

    private let session: URLSession
    private let urlString: String

    // MARK: - Initializer

    init(
        session: URLSession = .shared,
        urlString: String = RemoteCarbItemsDataSourceDefault.carbItemsUrlString
    ) {
        self.session = session
        self.urlString = urlString
    }

    // MARK: - RemoteCarbItemsDataSource

    func fetchCarbItems() async throws -> [CarbItemDto] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([CarbItemDto].self, from: data)
    }
}
