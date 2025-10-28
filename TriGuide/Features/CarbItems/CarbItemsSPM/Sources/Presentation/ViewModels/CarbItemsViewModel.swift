//
// TriGuide 2025
//

import Foundation

@MainActor
public class CarbItemsViewModel: ObservableObject {
    enum ViewState: Equatable {
        case unloaded
        case loading
        case loaded
    }

    @Published var state: ViewState = .unloaded
    @Published var errorMessage: String? = nil
    @Published var carbItems: [CarbItem] = []

    let loadCarbItemsUseCase: LoadCarbItemsUseCase

    init(loadCarbItemsUseCase: LoadCarbItemsUseCase) {
        self.loadCarbItemsUseCase = loadCarbItemsUseCase
    }
}

extension CarbItemsViewModel {
    func loadCarbItems() async {
        state = .loading
        do {
            let useCase = loadCarbItemsUseCase
            carbItems = try await useCase.execute()
            state = .loaded
        } catch {
            handle(error)
            state = .unloaded
        }
    }
}

private extension CarbItemsViewModel {
    func handle(_ error: Error) {
        errorMessage = "TODO: handle error"
    }
}

