//
//  TriGuide 2025
//

import SwiftUI

public extension View {

    // Applies card background to the view
    func cardBackground(
        backgroundColor: Color = Color.Primary.white
    ) -> some View {
        modifier(
            CardBackground(backgroundColor: backgroundColor)
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
