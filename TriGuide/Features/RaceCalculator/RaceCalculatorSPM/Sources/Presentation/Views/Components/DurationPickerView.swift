//
//  TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI

public struct DurationPickerView: View {
    public enum Mode {
        case regular
        case compact

        public var labelOrientation: PickerLabelOrientation {
            switch self {
            case .regular: return .vertical
            case .compact: return .horizontal
            }
        }
    }

    let title: String
    let mode: Mode
    let showHours: Bool
    @Binding var duration: TimeInterval?

    public init(
        title: String,
        mode: Mode = .regular,
        showHours: Bool = true,
        duration: Binding<TimeInterval?>
    ) {
        self.title = title
        self.mode = mode
        self.showHours = showHours
        _duration = duration
    }

    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var showPicker = false

    public var body: some View {
        Button {
            showPicker.toggle()
        } label: {
            pickerLabel
        }
        .sheet(isPresented: $showPicker) {
            timePicker
        }
        .onAppear { updateStateFromDuration() }
        .onChange(of: duration) { updateStateFromDuration() }
    }
}

// MARK: - Views

private extension DurationPickerView {
    @ViewBuilder
    var pickerLabel: some View {
        PickerLabel(
            orientation: mode.labelOrientation,
            title: "\(title): ",
            value: formattedDuration
        ) {
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(showPicker ? 180 : 0))
                .font(.Custom.Medium.font3)
        }
    }

    var timePicker: some View {
        TimePickerView(
            hours: showHours ? $hours : nil,
            minutes: $minutes,
            seconds: $seconds,
            maxHours: 100
        ) {
            updateDurationFromState()
            showPicker = false
        }
        .onChange(of: hours) {
            updateDurationFromState()
        }
        .onChange(of: minutes) {
            updateDurationFromState()
        }
        .onChange(of: seconds) {
            updateDurationFromState()
        }
    }
}

// MARK: - Helpers

private extension DurationPickerView {
    var formattedDuration: String {
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    // MARK: - State management

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
        title: Localizables.PaceCalculator.time,
        duration: .constant(3600)
    )
}
