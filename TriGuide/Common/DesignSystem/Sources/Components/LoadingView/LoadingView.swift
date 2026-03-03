//
// TriGuide 2026
//

import Localization
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
            ProgressView()
                .controlSize(.large)
                .accessibilityHint(Localizables.AccessibilityHints.loading)
        }
    }
}
