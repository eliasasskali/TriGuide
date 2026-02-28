//
// TriGuide 2026
//

import SwiftUI

public struct ToastView: View {
    // MARK: - Dependencies

    let message: String

    // MARK: - Initializer

    public init(message: String) {
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 8)
    }
}
