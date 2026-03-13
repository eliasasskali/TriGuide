//
// TriGuide 2025
//

import Localization
import SwiftUI
import TriGuideDomain

public struct IntervalBreakdownView: View {
    // MARK: - Dependencies

    private let breakdown: [IntervalFueling]

    // MARK: - Initializer

    public init(breakdown: [IntervalFueling]) {
        self.breakdown = breakdown
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            compactHeader
                .padding(.bottom, 8)

            ForEach(breakdown, id: \.index) { interval in
                compactRow(interval: interval)
            }
        }
    }
}

// MARK: - Private methods

private extension IntervalBreakdownView {
    var compactHeader: some View {
        HStack(spacing: 0) {
            Text("")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(Localizables.RaceNutritionResults.intervalCarbsLabel)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text(Localizables.RaceNutritionResults.intervalCaffeineLabel)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text(Localizables.RaceNutritionResults.intervalLiquidLabel)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.Custom.Medium.font2)
        .foregroundStyle(.secondary)
    }

    func compactRow(interval: IntervalFueling) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(interval.formatted)
                    .font(.Custom.Medium.font3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(
                    String(
                        format: "%.0f %@",
                        interval.carbGrams,
                        Localizables.Units.gSymbol
                    )
                )
                .frame(maxWidth: .infinity, alignment: .trailing)

                Text(
                    String(
                        format: "%.0f %@",
                        interval.caffeine,
                        Localizables.Units.mgSymbol
                    )
                )
                .frame(maxWidth: .infinity, alignment: .trailing)

                Text(
                    String(
                        format: "%.0f %@",
                        interval.waterVolumeML,
                        Localizables.Units.mlSymbol
                    )
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.Custom.Regular.font3)
            .padding(.vertical, 8)

            Divider()
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
        ),
    ]

    var body: some View {
        IntervalBreakdownView(breakdown: breakDown)
    }
}

#Preview("Compact & Expanded") {
    PreviewWrapper()
        .padding()
}
