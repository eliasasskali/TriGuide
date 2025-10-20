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
