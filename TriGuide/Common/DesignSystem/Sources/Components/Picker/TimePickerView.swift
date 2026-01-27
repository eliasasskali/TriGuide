//
// TriGuide 2025
//

import Localization
import SwiftUI

public struct TimePickerView: View {
    let hours: Binding<Int>?
    let minutes: Binding<Int>?
    let seconds: Binding<Int>?

    let maxHours: Int
    let onDoneClick: (() -> Void)?

    public init(
        hours: Binding<Int>? = nil,
        minutes: Binding<Int>? = nil,
        seconds: Binding<Int>? = nil,
        maxHours: Int = 24,
        onDoneClick: (() -> Void)? = nil
    ) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.maxHours = maxHours
        self.onDoneClick = onDoneClick
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                if let hours {
                    NumberWheelPicker(
                        selection: hours,
                        maxValue: maxHours,
                        label: Localizables.Units.hourSymbol
                    )
                }
                if let minutes {
                    NumberWheelPicker(
                        selection: minutes,
                        maxValue: 60,
                        label: Localizables.Units.minuteSymbol
                    )
                }
                if let seconds {
                    NumberWheelPicker(
                        selection: seconds,
                        maxValue: 60,
                        label: Localizables.Units.secondSymbol
                    )
                }
            }
            .frame(height: 100)

            HStack {
                Spacer()
                Button(Localizables.Common.done) {
                    onDoneClick?()
                }
                .padding(.trailing)
            }
        }
        .padding(12)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    NumberPickerView(
        whole: .constant(0),
        decimal: nil,
        maxWhole: 100
    ) {}
}
