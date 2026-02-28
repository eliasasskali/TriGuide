//
// TriGuide 2026
//

import SwiftUI

struct ToastModifier: ViewModifier {
    // MARK: - Dependencies

    @Binding var isPresented: Bool
    let message: String
    let duration: TimeInterval

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    ToastView(message: message)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: isPresented)
            .onChange(of: isPresented) { _, newValue in
                guard newValue else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
            .sensoryFeedback(.success, trigger: isPresented)
    }
}

// MARK: - View Extension

public extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        duration: TimeInterval = 2
    ) -> some View {
        modifier(
            ToastModifier(
                isPresented: isPresented,
                message: message,
                duration: duration
            )
        )
    }
}
