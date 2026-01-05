//
// TriGuide 2025
//

import SwiftUI
import TriGuideDomain
import Localization

public struct TimeBreakdownView: View {

    private var breakdown: [IntervalFueling]

    public init(breakdown: [IntervalFueling]) {
        self.breakdown = breakdown
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(breakdown, id: \.index) { interval in
                VStack(alignment: .leading, spacing: 16) {
                    Text("Interval: \(interval.formatted)")
                        .font(.Custom.Medium.font4)

                    Grid {
                        GridRow {
                            Text("Carbohydrates:")
                                .font(.Custom.Medium.font3)

                            Text("\(interval.carbGrams, specifier: "%.0f") \(Localizables.Units.gSymbol)")
                                .font(.Custom.Regular.font3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)

                        Divider()

                        GridRow {
                            Text("Caffeine:")
                                .font(.Custom.Medium.font3)

                            Text("\(interval.caffeine, specifier: "%.0f") \(Localizables.Units.mgSymbol)")
                                .font(.Custom.Regular.font3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)

                        Divider()

                        GridRow {
                            Text("Liquid:")
                                .font(.Custom.Medium.font3)

                            Text("\(interval.waterVolumeML, specifier: "%.0f") \(Localizables.Units.mlSymbol)")
                                .font(.Custom.Regular.font3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)

                        Divider()
                    }
                }
            }
        }
    }
}


// MARK: - Preview

private struct PreviewWrapper: View {
    var breakDown: [IntervalFueling] = [
        .init(
            duration: 1800,
            hourIndex: 0,
            carbGrams: 74,
            caffeine: 100,
            waterVolumeML: 555
        ),
        .init(
            duration: 1800,
            hourIndex: 1,
            carbGrams: 53,
            caffeine: 0,
            waterVolumeML: 333
        ),
        .init(
            duration: 1800,
            hourIndex: 2,
            carbGrams: 99.8,
            caffeine: 140,
            waterVolumeML: 311
        ),
        .init(
            duration: 1800,
            hourIndex: 3,
            carbGrams: 73,
            caffeine: 60,
            waterVolumeML: 300
        )
    ]

    var body: some View {
        TimeBreakdownView(breakdown: breakDown)
    }
}

#Preview {
    PreviewWrapper()
        .padding()
}
