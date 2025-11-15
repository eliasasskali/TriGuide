//
// TriGuide
//

import SwiftUI

// TODO: Solve contrast issue with .ultraThinMaterial background in popover

public struct InfoLabel<Content: View>: View {
    let title: String?
    let content: Content

    @State private var showPopover = false
    @State private var measuredHeight: CGFloat = 0

    public init(
        title: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
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
        let finalHeight = min(max(measuredHeight, 80), 240)

        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let title {
                    Text(title).font(.headline)
                    Divider()
                }

                content
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { measuredHeight = geo.size.height }
                        .onChange(of: geo.size.height) { _, newHeight in
                            measuredHeight = newHeight
                        }
                }
            )
        }
        .frame(height: finalHeight)
        .scrollIndicators(.hidden)
        .background(.ultraThinMaterial)
        .presentationCompactAdaptation(.popover)
        .presentationBackground(.clear)
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

extension View {
    func infoTextStyle() -> some View {
        self
            .font(.footnote)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}
