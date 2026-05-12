//
// TriGuide 2026
//

import SwiftUI

struct FloatingActionButtonModifier: ViewModifier {
    // MARK: - Dependencies

    let title: String
    let systemImage: String
    let bottomPadding: CGFloat
    let action: () -> Void

    // MARK: - Body

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content

            Button(action: action) {
                Label(title, systemImage: systemImage)
            }
            .buttonStyle(.borderedProminent)
            .padding(.trailing, 20)
            .padding(.bottom, bottomPadding)
        }
    }
}

// MARK: - View Extension

public extension View {
    func floatingActionButton(
        _ title: String,
        systemImage: String,
        bottomPadding: CGFloat = 20,
        action: @escaping () -> Void
    ) -> some View {
        modifier(
            FloatingActionButtonModifier(
                title: title,
                systemImage: systemImage,
                bottomPadding: bottomPadding,
                action: action
            )
        )
    }
}
