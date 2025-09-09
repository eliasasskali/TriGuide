//
//  TriGuide 2025
//

import SwiftUI

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
    let range: ClosedRange<Int>
    let maxDecimal: Int = 9
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
            value: compactValue
        ) {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
        }
    }

    var regularPickerLabel: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String("\(title):"))
                    .foregroundStyle(.black)
                Text(compactValue)
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2)
        )
    }

    var compactPickerLabel: some View {
        HStack {
            Text(String("\(title): "))
                .foregroundStyle(.black)
            Text(compactValue)
                .font(.subheadline)
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
        }
        .padding(8)
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2)
        )
    }

    var pickerSheet: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                pickerWheel($whole, values: Array(range))
                Text(String(".")).font(.title).frame(width: 10)
                pickerWheel($decimal, values: Array(0...maxDecimal))
                if let unit { Text(unit).padding(.leading, 8) }
            }
            .frame(height: 100)

            HStack {
                Spacer()
                Button(Localizables.Common.done) {
                    showPicker = false
                }
                .padding(.trailing)
            }
        }
        .padding(12)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden)
        .background(Color(UIColor.systemBackground))
    }

    func pickerWheel(_ selection: Binding<Int>, values: [Int]) -> some View {
        Picker(selection: selection, label: Text("")) {
            ForEach(values, id: \.self) { Text(String("\($0)")) }
        }
        .pickerStyle(WheelPickerStyle())
        .frame(width: 60, height: 90)
        .clipped()
        .onChange(of: selection.wrappedValue) {
            updateValueFromState()
            onChange?()
        }
    }
}

// MARK: - Helpers

private extension DecimalPickerView {
    var compactValue: String {
        guard let value else { return "0.0" }
        return showUnitOnLabel ? String(format: "%.1f %@", value, unit ?? "") : String(format: "%.1f", value)
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
