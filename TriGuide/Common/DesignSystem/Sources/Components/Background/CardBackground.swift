//
//  TriGuide 2025
//

import SwiftUI

struct CardBackground: ViewModifier {
    var backgroundColor: Color = .Primary.white
    var innerPadding: CGFloat

    let cornerRadius: CGFloat = 10
    let shadowRadius: CGFloat = 2
    
    func body(content: Content) -> some View {
        content
            .padding(innerPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.15), radius: shadowRadius)
            )
    }
}
