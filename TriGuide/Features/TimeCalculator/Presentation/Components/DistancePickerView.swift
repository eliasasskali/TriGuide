//
//  DistancePickerView.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 24/8/25.
//

import SwiftUI

struct DistancePickerView: View {
    let title: String
    @Binding var distance: Double?
    var unit: DistanceUnit?
    var onChangeDistance: (() -> Void)? = nil

    @State private var whole = 0
    @State private var decimal = 0
    @State private var showPicker = false
    @State private var selectedUnit: DistanceUnit?

    var body: some View {
        Button {
            showPicker.toggle()
        } label: {
            HStack {
                Text("\(title): ")
                    .foregroundStyle(.black)
                Text(compactFormattedDistance)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(showPicker ? 180 : 0))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showPicker) {
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
                            label: selectedUnitLabel
                        )
                        .frame(height: 100)

                        unitPicker
                    }
                }

                HStack {
                    Spacer()
                    Button("Done") {
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
        .onAppear { updateStateFromDistance() }
        .onChange(of: distance) { updateStateFromDistance() }
    }

    // MARK: - Wheels

    func distanceWheel(_ selection: Binding<Int>, values: [Int], label: String) -> some View {
        VStack(spacing: 4) {
            Picker(selection: selection, label: Text(label)) {
                ForEach(values, id: \.self) { Text("\($0)") }
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
            get: { selectedUnit ?? unit ?? .kilometers },
            set: { selectedUnit = $0; updateDistanceFromState() }
        )) {
            if usesDecimals {
                Text("km").tag(DistanceUnit.kilometers)
                Text("mi").tag(DistanceUnit.miles)
            } else {
                Text("m").tag(DistanceUnit.meters)
                Text("yd").tag(DistanceUnit.yards)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 80, height: 90)
    }
}

private extension DistancePickerView {

    // MARK: - Display helpers

    var compactFormattedDistance: String {
        guard let distance, let baseUnit = unit else { return "Distance (\(unitLabel))" }
        let effectiveUnit = selectedUnit ?? baseUnit
        let value = distance / effectiveUnit.factorToMeters

        if usesDecimals {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 3
            formatter.numberStyle = .decimal
            let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
            return "\(formatted) \(effectiveUnit.localized)"
        } else {
            return "\(Int(value)) \(effectiveUnit.localized)"
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

    var unitLabel: String {
        unit?.localized ?? "unit"
    }

    var selectedUnitLabel: String {
        selectedUnit?.localized ?? unit?.localized ?? "unit"
    }

    // MARK: - State management

    func updateStateFromDistance() {
        guard let distance, let baseUnit = unit else { return }

        let effectiveUnit = selectedUnit ?? baseUnit
        let value = distance / effectiveUnit.factorToMeters
        whole = Int(floor(value))

        if usesDecimals {
            let decimalValue = ((value - Double(whole)) * 10).rounded()
            decimal = min(Int(decimalValue), 9)
        }
    }

    func updateDistanceFromState() {
        guard let baseUnit = unit else { return }

        let effectiveUnit = selectedUnit ?? baseUnit
        let value = Double(whole) + (usesDecimals ? Double(decimal) / 10.0 : 0)
        distance = value * effectiveUnit.factorToMeters
        onChangeDistance?()
    }
}
