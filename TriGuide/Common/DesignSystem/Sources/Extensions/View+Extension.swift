//
//  TriGuide 2025
//

import SwiftUI

public extension View {

    // Applies card background to the view
    func cardBackground(
        backgroundColor: Color = .Primary.white,
        innerPadding: CGFloat
    ) -> some View {
        modifier(
            CardBackground(
                backgroundColor: backgroundColor,
                innerPadding: innerPadding
            )
        )
    }

    // Conditional modifier
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
