//
// TriGuide 2025
//

import SwiftUI

public struct ActionButton: View {
    public enum Style {
        case primary
        case secondary
        case destructive
    }

    let title: String
    let style: Style
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    public init(
        _ title: String,
        style: Style = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard !isLoading && !isDisabled else { return }
            action()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(isDisabled || isLoading)
        .controlSize(.large)
        .applyNativeStyle(style: style)
    }
}

// MARK: - Private properties

private extension View {
    @ViewBuilder
    func applyNativeStyle(style: ActionButton.Style) -> some View {
        switch style {
        case .primary:
            self
                .buttonStyle(.borderedProminent)
                .tint(Color.accentColor)
        case .secondary:
            self
                .buttonStyle(.bordered)
                .tint(Color(UIColor.systemGray))
        case .destructive:
            self
                .buttonStyle(.borderedProminent)
                .tint(Color(UIColor.systemRed))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ActionButton(
            "Primary Button",
            style: .primary,
            action: { }
        )

        ActionButton(
            "Disabled Primary Button",
            style: .primary,
            isDisabled: true,
            action: { }
        )

        ActionButton(
            "Loading Primary Button",
            style: .primary,
            isLoading: true,
            action: { }
        )

        ActionButton(
            "Secondary Button",
            style: .secondary,
            action: { }
        )

        ActionButton(
            "Destructive Button",
            style: .destructive,
            action: { }
        )
    }
    .padding()
}
