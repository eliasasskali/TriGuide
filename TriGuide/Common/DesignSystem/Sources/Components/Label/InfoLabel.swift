//
// TriGuide
//

import SwiftUI

public struct InfoLabel<Content: View>: View {
    let title: String?
    let content: () -> Content

    @State private var showPopover = false

    public init(
        title: String? = nil,
        content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
    }

    public var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            Image(systemName: "info.circle")
                .imageScale(.medium)
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPopover) {
            popoverView
        }
    }
}

private extension InfoLabel {
    var popoverView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let title {
                    Text(title).font(.headline)
                    Divider()
                }

                content()
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .frame(idealWidth: 280, maxHeight: 300)
        .fixedSize(horizontal: false, vertical: true)
        .presentationCompactAdaptation(.popover)
    }
}

#Preview {
    InfoLabel(
        title: "Information",
        content: {
            VStack(alignment: .leading, spacing: 6) {
                Text("Think of this as a **starting point** for your fueling.")
                Text("• The numbers are **capped for safety**, ideal for athletes without gut training.")
                Text("• If you’ve trained your gut, you can **unlock the full range** in Advanced Options.")
                Text("• Everyone’s body is different — use this as a guide and **adjust based on how you feel**.")
            }
            .lineLimit(nil)
        }
    )
}
