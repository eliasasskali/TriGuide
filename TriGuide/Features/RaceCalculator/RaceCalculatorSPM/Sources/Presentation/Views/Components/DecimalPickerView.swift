//
//  TriGuide 2025
//

import SwiftUI
import DesignSystem

struct DecimalPickerView: View {
    enum Mode {
        case regular
        case compact

        var labelOrientation: PickerLabelOrientation {
            switch self {
            case .regular: return .vertical
            case .compact: return .horizontal
            }
        }
    }

    let title: String
    @Binding var value: Double?
    let maxWhole: Int = 100
    let unit: String?
    let showUnitOnLabel: Bool
    let mode: Mode

    var onChange: (() -> Void)? = nil

    @State private var whole = 0
    @State private var decimal = 0
    @State private var showPicker = false

    var body: some View {
        Button {
            showPicker.toggle()
        } label: {
            pickerLabel
        }
        .sheet(isPresented: $showPicker) {
            pickerSheet
        }
        .onAppear { updateStateFromValue() }
        .onChange(of: value) { updateStateFromValue() }
    }
}

// MARK: - Views

private extension DecimalPickerView {
    @ViewBuilder
    var pickerLabel: some View {
        PickerLabel(
            orientation: mode.labelOrientation,
            title: "\(title):",
            value: formattedValue
        ) {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
        }
    }

    var pickerSheet: some View {
        NumberPickerView(
            whole: $whole,
            decimal: $decimal,
            maxWhole: maxWhole,
            label: {
                if let unit { Text(unit).padding(.leading, 8) }
            }
        ) {
            showPicker = false
        }
        .onChange(of: whole) {
            updateValueFromState()
            onChange?()
        }
        .onChange(of: decimal) {
            updateValueFromState()
            onChange?()
        }
    }
}

// MARK: - Helpers

private extension DecimalPickerView {
    var formattedValue: String {
        guard let localizedValue = value?.formattedAsDecimal(minFractionDigits: 1) else {
            return 0.formattedAsDecimal(minFractionDigits: 1)
        }
        return showUnitOnLabel ? "\(localizedValue) \(unit ?? "")" : localizedValue
    }

    func updateStateFromValue() {
        guard let value else { return }
        whole = Int(floor(value))
        decimal = Int(((value - Double(whole)) * 10).rounded())
    }

    func updateValueFromState() {
        value = Double(whole) + Double(decimal)/10.0
    }
}
