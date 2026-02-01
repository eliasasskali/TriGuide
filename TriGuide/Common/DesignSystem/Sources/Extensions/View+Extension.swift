//
//  TriGuide 2025
//

import SwiftUI

public extension View {
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
