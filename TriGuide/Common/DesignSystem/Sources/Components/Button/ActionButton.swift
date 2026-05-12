//
// TriGuide 2025
//

import Localization
import SwiftUI

public struct ActionButton: View {
    public enum Style {
        case primary
        case secondary
        case destructive
    }

    // MARK: - Dependencies

    let title: String
    let style: Style
    let isLoading: Bool
    let isDisabled: Bool
    let accessibilityLabel: String?
    let accessibilityHint: String?
    let action: () -> Void

    // MARK: - Initializer

    public init(
        _ title: String,
        style: Style = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    // MARK: - Computed properties

    private var accessibilityHintText: String {
        return if isLoading {
            Localizables.AccessibilityHints.loading
        } else if isDisabled {
            Localizables.AccessibilityHints.disabled
        } else {
            accessibilityHint ?? ""
        }
    }

    private var accessibilityLabelText: String {
        accessibilityLabel ?? title
    }

    // MARK: - Body

    public var body: some View {
        Button(action: {
            guard !isLoading, !isDisabled else { return }
            action()
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(isDisabled || isLoading)
        .controlSize(.large)
        .applyNativeStyle(style: style)
        .accessibilityLabel(accessibilityLabelText)
        .if(!accessibilityHintText.isEmpty) {
            $0.accessibilityHint(accessibilityHintText)
        }
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Private properties

private extension View {
    @ViewBuilder
    func applyNativeStyle(style: ActionButton.Style) -> some View {
        switch style {
        case .primary:
            buttonStyle(.borderedProminent)
                .tint(Color.accentColor)
        case .secondary:
            buttonStyle(.bordered)
                .tint(Color(UIColor.systemGray))
        case .destructive:
            buttonStyle(.borderedProminent)
                .tint(Color(UIColor.systemRed))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ActionButton(
            "Primary Button",
            style: .primary,
            action: {}
        )

        ActionButton(
            "Disabled Primary Button",
            style: .primary,
            isDisabled: true,
            action: {}
        )

        ActionButton(
            "Loading Primary Button",
            style: .primary,
            isLoading: true,
            action: {}
        )

        ActionButton(
            "Secondary Button",
            style: .secondary,
            action: {}
        )

        ActionButton(
            "Destructive Button",
            style: .destructive,
            action: {}
        )
    }
    .padding()
}
