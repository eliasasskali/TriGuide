//
//  TriGuide 2025
//

import SwiftUI

/// Applies card background to the view
struct CardBackground: ViewModifier {
    // MARK: - Constants

    enum Constants {
        static let cornerRadius: CGFloat = 10
        static let shadowRadius: CGFloat = 2
    }

    // MARK: - Dependencies

    var backgroundColor: Color = .Primary.white
    var innerHorizontalPadding: CGFloat
    var innerVerticalPadding: CGFloat

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, innerHorizontalPadding)
            .padding(.vertical, innerVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.15), radius: Constants.shadowRadius)
            )
    }
}

// MARK: - View Extension

public extension View {
    func cardBackground(
        backgroundColor: Color = .Primary.white,
        innerHorizontalPadding: CGFloat = 16,
        innerVerticalPadding: CGFloat = 16
    ) -> some View {
        modifier(
            CardBackground(
                backgroundColor: backgroundColor,
                innerHorizontalPadding: innerHorizontalPadding,
                innerVerticalPadding: innerVerticalPadding
            )
        )
    }
}
