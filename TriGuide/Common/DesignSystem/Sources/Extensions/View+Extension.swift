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

    @ViewBuilder
    func hideKeyboardOnTap() -> some View {
        #if canImport(UIKit)
            simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.resignFirstResponder()
                }
            )
        #else
            self
        #endif
    }
}
