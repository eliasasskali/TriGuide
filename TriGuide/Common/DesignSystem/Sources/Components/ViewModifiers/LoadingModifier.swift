//
// TriGuide 2025
//

import SwiftUI

/// Shows a loading spinner that blocks the screen when `isLoading` is true.
struct LoadingModifier: ViewModifier {
    // MARK: - Dependencies

    @Binding var isLoading: Bool

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .if(isLoading) { view in
                view
                    .overlay {
                        LoadingView()
                    }
            }
            .disabled(isLoading)
    }
}

// MARK: - View Extension

public extension View {
    func loadingOverlay(isLoading: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
}
