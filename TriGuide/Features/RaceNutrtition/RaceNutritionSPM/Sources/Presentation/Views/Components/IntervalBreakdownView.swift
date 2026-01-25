//
// TriGuide 2025
//

import SwiftUI
import TriGuideDomain
import Localization

public struct IntervalBreakdownView: View {

    // MARK: - Dependencies

    private let breakdown: [IntervalFueling]

    // MARK: - Initializer

    public init(breakdown: [IntervalFueling]) {
        self.breakdown = breakdown
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(breakdown, id: \.index) { interval in
                intervalInfo(interval: interval)
            }
        }
    }
}

// MARK: - Private methods

private extension IntervalBreakdownView {
    func intervalHeader(title: String) -> some View {
        Text(Localizables.RaceNutritionResults.interval(title))
            .font(.Custom.Medium.font4)
    }

    func intervalInfo(interval: IntervalFueling) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            intervalHeader(title: interval.formatted)
            Grid {
                infoRow(
                    label: Localizables.RaceNutritionResults.intervalCarbsLabel,
                    value: interval.carbGrams,
                    unit: Localizables.Units.gSymbol
                )

                Divider()

                infoRow(
                    label: Localizables.RaceNutritionResults.intervalCaffeineLabel,
                    value: interval.caffeine,
                    unit: Localizables.Units.mgSymbol
                )

                Divider()

                infoRow(
                    label: Localizables.RaceNutritionResults.intervalLiquidLabel,
                    value: interval.waterVolumeML,
                    unit: Localizables.Units.mlSymbol
                )

                Divider()
            }
        }
    }

    func infoRow(
        label: String,
        value: Double,
        unit: String
    ) -> some View {
        GridRow {
            Text(label)
                .font(.Custom.Medium.font3)

            Text(
                String(
                    format: "%.0f %@",
                    value,
                    unit
                )
            )
            .font(.Custom.Regular.font3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
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
        IntervalBreakdownView(breakdown: breakDown)
    }
}

#Preview {
    PreviewWrapper()
        .padding()
}
