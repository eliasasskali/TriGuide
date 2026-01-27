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

    @State private var pickerWidth: CGFloat = 70

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
        VStack(spacing: 4) {
            Picker(selection: $selection, label: Text(label ?? "")) {
                ForEach(values, id: \.self) { value in
                    Text(String(value))
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: pickerWidth, height: 80)
            .clipped()
            .fixedSize(horizontal: true, vertical: false)
            .onChange(of: selection) { _, newValue in
                updatePickerWidth(for: newValue)
            }

            if let label {
                Text(label)
                    .font(.caption2)
                    .lineLimit(1)
                    .frame(width: pickerWidth)
            }
        }
    }
}

private extension NumberWheelPicker {
    func updatePickerWidth(for value: Int) {
        if value < 1000 {
            pickerWidth = 70
        } else {
            pickerWidth = 100
        }
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
