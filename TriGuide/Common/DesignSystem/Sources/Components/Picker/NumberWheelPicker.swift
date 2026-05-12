//
// TriGuide 2025
//

import SwiftUI

public struct NumberWheelPicker: View {
    @Binding var selection: Int
    let minValue: Int
    let maxValue: Int
    let step: Int
    let label: String?

    @State private var scrolledID: Int?

    private let itemHeight: CGFloat = 36

    public init(
        selection: Binding<Int>,
        minValue: Int = 0,
        maxValue: Int,
        step: Int = 1,
        label: String? = nil
    ) {
        _selection = selection
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
        self.label = label
    }

    private var values: [Int] {
        Array(stride(from: minValue, through: maxValue, by: step))
    }

    public var body: some View {
        VStack(spacing: 2) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.tertiarySystemFill))
                    .frame(height: itemHeight)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(values, id: \.self) { value in
                            Text(String(value))
                                .font(.title3.monospacedDigit())
                                .fontWeight(value == (scrolledID ?? selection) ? .medium : .regular)
                                .foregroundStyle(value == (scrolledID ?? selection) ? .primary : .secondary)
                                .frame(height: itemHeight)
                                .frame(maxWidth: .infinity)
                                .id(value)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrolledID)
                .contentMargins(.vertical, itemHeight, for: .scrollContent)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.35),
                            .init(color: .black, location: 0.65),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(width: pickerWidth, height: itemHeight * 3)

            if let label {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .sensoryFeedback(.selection, trigger: scrolledID)
        .onAppear { scrolledID = selection }
        .onChange(of: scrolledID) { _, newValue in
            guard let newValue, newValue != selection else { return }
            selection = newValue
        }
        .onChange(of: selection) { _, newValue in
            guard newValue != scrolledID else { return }
            withAnimation(.snappy(duration: 0.2)) {
                scrolledID = newValue
            }
        }
    }

    private var pickerWidth: CGFloat {
        maxValue >= 1000 ? 100 : 70
    }
}

#Preview {
    NumberWheelPicker(
        selection: .constant(0),
        minValue: 0,
        maxValue: 100_000,
        step: 100,
        label: "label"
    )
}
