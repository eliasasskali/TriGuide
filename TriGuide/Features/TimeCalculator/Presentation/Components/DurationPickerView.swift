//
//  TriGuide 2025
//

import SwiftUI

struct DurationPickerView: View {
    enum Mode {
        case regular
        case compact
    }

    let title: String
    let mode: Mode

    @Binding var duration: TimeInterval?

    init(
        title: String,
        mode: Mode = .regular,
        duration: Binding<TimeInterval?>
    ) {
        self.title = title
        self.mode = mode
        self._duration = duration
    }

    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
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
        .onAppear { updateStateFromDuration() }
        .onChange(of: duration) { updateStateFromDuration() }
    }
}

private extension DurationPickerView {
    func durationWheel(_ selection: Binding<Int>, range: Range<Int>, label: String) -> some View {
        VStack(spacing: 4) {
            Picker(selection: selection, label: Text(label)) {
                ForEach(range, id: \.self) { Text("\($0)") }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: selection.wrappedValue) {
                updateDurationFromState()
            }
            .frame(width: 60, height: 90)
            .clipped()

            Text(label).font(.caption2)
        }
    }

    var formattedDuration: String {
        var components: [String] = []

        if hours > 0 {
            components.append("\(hours)h")
        }
        if minutes > 0 {
            components.append("\(minutes)m")
        }
        if seconds > 0 || components.isEmpty {
            components.append("\(seconds)s")
        }

        return components.joined()
    }

    var compactFormattedDuration: String {
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    @ViewBuilder
    var pickerLabel: some View {
        switch mode {
        case .regular:
            regularPickerLabel
        case .compact:
            compactPickerLabel
        }
    }

    var pickerSheet: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                if mode == .regular {
                    durationWheel($hours, range: 0..<24, label: "h")
                }
                durationWheel($minutes, range: 0..<60, label: "m")
                durationWheel($seconds, range: 0..<60, label: "s")
            }
            .frame(height: 100)

            HStack {
                Spacer()
                Button("Done") {
                    updateDurationFromState()
                    showPicker = false
                }
                .padding(.trailing)
            }
        }
        .padding(12)
        .cornerRadius(12)
        .presentationDetents([.height(180)])
        .presentationDragIndicator(.hidden)
        .background(Color(UIColor.systemBackground))
    }

    var regularPickerLabel: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(title):")
                    .foregroundStyle(.black)
                Text(compactFormattedDuration)
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }

    var compactPickerLabel: some View {
        HStack {
            Text("\(title): ")
                .foregroundStyle(.black)
            Text(compactFormattedDuration)
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

    func updateStateFromDuration() {
        guard let duration else { return }
        let totalSeconds = Int(duration)
        hours = totalSeconds / 3600
        minutes = (totalSeconds % 3600) / 60
        seconds = totalSeconds % 60
    }

    func updateDurationFromState() {
        duration = TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }
}

#Preview {
    DurationPickerView(
        title: "Duration",
        duration: .constant(3600)
    )
}
