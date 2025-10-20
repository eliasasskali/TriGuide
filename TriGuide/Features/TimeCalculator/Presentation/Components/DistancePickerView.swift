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
            value: compactFormattedDistance
        ) {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
                .font(.Custom.Medium.font3)
        }
    }

    var pickerSheet: some View {
        VStack(spacing: 8) {
            if usesDecimals {
                HStack(spacing: 0) {
                    distanceWheel($whole, values: Array(0..<1000), label: "")
                    Text(".")
                        .font(.title)
                        .frame(width: 10)
                    distanceWheel($decimal, values: Array(0..<10), label: "")
                    unitPicker
                }
                .frame(height: 100)
            } else {
                HStack() {
                    distanceWheel(
                        $whole,
                        values: Array(stride(from: 0, through: 100000, by: 50)),
                        label: unit.localized
                    )
                    .frame(height: 100)

                    unitPicker
                }
            }

            HStack {
                Spacer()
                Button(Localizables.Common.done) {
                    updateDistanceFromState()
                    showPicker = false
                }
                .padding(.trailing)
            }
        }
        .padding(12)
        .cornerRadius(12)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden)
        .background(Color(UIColor.systemBackground))
    }

    func distanceWheel(_ selection: Binding<Int>, values: [Int], label: String) -> some View {
        VStack(spacing: 4) {
            Picker(selection: selection, label: Text(label)) {
                ForEach(values, id: \.self) { Text(String($0)) }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: selection.wrappedValue) {
                updateDistanceFromState()
            }
            .frame(width: 150, height: 90)
            .clipped()

            if !label.isEmpty {
                Text(label).font(.caption2)
            }
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
    var compactFormattedDistance: String {
        guard let distance else { return "0 \(unit.localized)" }
        let value = distance / unit.factorToMeters

        if usesDecimals {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 3
            formatter.numberStyle = .decimal
            let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
            return "\(formatted) \(unit.localized)"
        } else {
            return "\(Int(value)) \(unit.localized)"
        }
    }

    var usesDecimals: Bool {
        switch unit {
        case .kilometers, .miles:
            true
        case .meters, .yards:
            false
        default:
            true
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
        let value = Double(whole) + (usesDecimals ? Double(decimal) / 10.0 : 0)
        distance = value * unit.factorToMeters
        onChangeDistance?()
    }
}
