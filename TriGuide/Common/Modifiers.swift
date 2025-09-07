//
//  TriGuide 2025
//

import SwiftUI

struct CardBackground: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(13)
            .shadow(color: Color.black.opacity(0.15), radius: 3)
    }
}

extension View {
    func cardBackground(
        backgroundColor: Color = Color(.primaryWhite)
    ) -> some View {
        modifier(
            CardBackground(backgroundColor: backgroundColor)
        )
    }

    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
