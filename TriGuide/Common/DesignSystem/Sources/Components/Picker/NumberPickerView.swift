//
// TriGuide 2025
//

import Localization
import SwiftUI

public struct NumberPickerView<Label: View>: View {
    @Binding var whole: Int
    let decimal: Binding<Int>?

    let maxWhole: Int
    let maxDecimal: Int
    let wholeStep: Int
    let decimalStep: Int
    let label: () -> Label
    let onDoneClick: (() -> Void)?

    public init(
        whole: Binding<Int>,
        decimal: Binding<Int>? = nil,
        maxWhole: Int,
        maxDecimal: Int = 9,
        wholeStep: Int = 1,
        decimalStep: Int = 1,
        @ViewBuilder label: @escaping () -> Label = { EmptyView() },
        onDoneClick: (() -> Void)? = nil
    ) {
        _whole = whole
        self.decimal = decimal
        self.maxWhole = maxWhole
        self.maxDecimal = maxDecimal
        self.wholeStep = wholeStep
        self.decimalStep = decimalStep
        self.label = label
        self.onDoneClick = onDoneClick
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                NumberWheelPicker(
                    selection: $whole,
                    minValue: 0,
                    maxValue: maxWhole,
                    step: wholeStep
                )
                if let decimal {
                    Text(decimalSeparator).font(.title).frame(width: 10)
                    NumberWheelPicker(
                        selection: decimal,
                        minValue: 0,
                        maxValue: maxDecimal,
                        step: decimalStep
                    )
                }
                label()
            }

            HStack {
                Spacer()
                Button(Localizables.Common.done) {
                    onDoneClick?()
                }
                .padding(.trailing)
            }
        }
        .padding(12)
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color(UIColor.systemBackground))
    }
}

private extension NumberPickerView {
    var decimalSeparator: String {
        NumberFormatter().decimalSeparator ?? ","
    }
}

#Preview {
    NumberPickerView(
        whole: .constant(0),
        decimal: nil,
        maxWhole: 100
    ) {}
}
