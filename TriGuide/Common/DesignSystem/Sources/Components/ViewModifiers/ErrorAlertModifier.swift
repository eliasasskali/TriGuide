//
// TriGuide 2025
//

import Localization
import SwiftUI

/// Shows an error alert when the bound message is non-nil.
struct ErrorAlertModifier: ViewModifier {
    // MARK: - Dependencies

    @Binding var message: String?

    // MARK: - Body

    func body(content: Content) -> some View {
        content.alert(
            Localizables.Common.error,
            isPresented: Binding(
                get: { message != nil },
                set: { if !$0 { message = nil } }
            )
        ) {
            Button(Localizables.Common.ok, role: .cancel) {
                message = nil
            }
        } message: {
            if let message {
                Text(message)
            }
        }
    }
}

// MARK: - View Extension

public extension View {
    func errorAlert(message: Binding<String?>) -> some View {
        modifier(ErrorAlertModifier(message: message))
    }
}
