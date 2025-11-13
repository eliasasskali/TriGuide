//
// TriGuide 2025
//

import SwiftUI

public struct QuantityPickerView: View {
    public enum Orientation {
        case horizontal, vertical
    }

    @Binding public var quantity: Int
    @State private var animateQuantity: Bool = false

    let onIncrementQuantity: ((Int) -> Void)?
    let onDecrementQuantity: ((Int) -> Void)?
    let orientation: Orientation

    public init(
        quantity: Binding<Int>,
        onIncrementQuantity: ((Int) -> Void)?,
        onDecrementQuantity: ((Int) -> Void)?,
        orientation: Orientation
    ) {
        self._quantity = quantity
        self.onIncrementQuantity = onIncrementQuantity
        self.onDecrementQuantity = onDecrementQuantity
        self.orientation = orientation
    }

    public var body: some View {
        Group {
            switch orientation {
            case .horizontal: horizontalPicker
            case .vertical: verticalPicker
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

private extension QuantityPickerView {
    var horizontalPicker: some View {
        HStack(spacing: 4) {
            minusButton
            quantityText
            plusButton
        }
    }

    var verticalPicker: some View {
        VStack(spacing: 4) {
            plusButton
            quantityText
            minusButton
        }
    }

    var minusButton: some View {
        button(systemName: "minus") {
            quantity = max(0, quantity - 1)
            animateQuantityChange()
            onDecrementQuantity?(quantity)
        }
    }

    var plusButton: some View {
        button(systemName: "plus") {
            quantity += 1
            animateQuantityChange()
            onIncrementQuantity?(quantity)
        }
    }

    var quantityText: some View {
        Text("\(quantity)")
            .font(.system(size: 14, weight: .medium))
            .scaleEffect(animateQuantity ? 1.3 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animateQuantity)
    }

    func button(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 25, height: 25, alignment: .center)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minWidth: 25, minHeight: 25)
        .contentShape(Rectangle())
    }

    func animateQuantityChange() {
        animateQuantity = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            animateQuantity = false
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        QuantityPickerView(
            quantity: .constant(5),
            onIncrementQuantity: { _ in },
            onDecrementQuantity: { _ in },
            orientation: .horizontal
        )

        QuantityPickerView(
            quantity: .constant(3),
            onIncrementQuantity: { _ in },
            onDecrementQuantity: { _ in },
            orientation: .vertical
        )
    }
    .padding()
}
