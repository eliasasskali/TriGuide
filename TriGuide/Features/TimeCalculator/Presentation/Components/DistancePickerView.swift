//
//  TriGuide 2025
//

import SwiftUI
import Localization
import DesignSystem

struct DistancePickerView: View {
    let title: String
    @Binding var distance: Double?
    @Binding var unit: DistanceUnit
    var onChangeDistance: (() -> Void)? = nil

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
        .onAppear { updateStateFromDistance() }
        .onChange(of: distance) { updateStateFromDistance() }
    }
}

// MARK: - Views

private extension DistancePickerView {
    var pickerLabel: some View {
        PickerLabel(
            orientation: .horizontal,
            title: "\(title): ",
            value: formattedDistance
        ) {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
                .font(.Custom.Medium.font3)
        }
    }

    var pickerSheet: some View {
        NumberPickerView(
            whole: $whole,
            decimal: usesDecimals ? $decimal : nil,
            maxWhole: usesDecimals ? 1000 : 100000,
            wholeStep: usesDecimals ? 1 : 50,
            label: {
                unitPicker
            }
        ) {
            showPicker = false
        }
        .onChange(of: whole) {
            updateDistanceFromState()
        }
        .onChange(of: decimal) {
            updateDistanceFromState()
        }
    }

    var unitPicker: some View {
        Picker("", selection: Binding(
            get: { unit },
            set: {
                unit = $0
                updateDistanceFromState()
            }
        )) {
            if usesDecimals {
                Text(Localizables.Units.kmSymbol).tag(DistanceUnit.kilometers)
                Text(Localizables.Units.miSymbol).tag(DistanceUnit.miles)
            } else {
                Text(Localizables.Units.mSymbol).tag(DistanceUnit.meters)
                Text(Localizables.Units.ydSymbol).tag(DistanceUnit.yards)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 80, height: 90)
    }
}

// MARK: - Helpers

private extension DistancePickerView {
    var formattedDistance: String {
        guard let distance else { return "0 \(unit.localized)" }
        let value = distance / unit.factorToMeters

        return "\(value.formattedAsDecimal()) \(unit.localized)"
    }

    var usesDecimals: Bool {
        switch unit {
        case .kilometers, .miles:
            true
        case .meters, .yards:
            false
        }
    }

    // MARK: - State management

    func updateStateFromDistance() {
        guard let distance else { return }

        let value = distance / unit.factorToMeters
        whole = Int(floor(value))

        if usesDecimals {
            let decimalValue = ((value - Double(whole)) * 10).rounded()
            decimal = min(Int(decimalValue), 9)
        }
    }

    func updateDistanceFromState() {
        let value = Double(whole) + Double(decimal) / 10.0
        distance = value * unit.factorToMeters
        onChangeDistance?()
    }
}
