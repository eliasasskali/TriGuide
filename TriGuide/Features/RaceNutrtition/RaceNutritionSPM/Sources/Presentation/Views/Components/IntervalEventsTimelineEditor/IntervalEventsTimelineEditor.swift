//
// TriGuide 2026
//

import TriGuideDomain
import SwiftUI
import Localization

struct IntervalEventsTimelineEditor: View {

    // MARK: - Constants

    enum Constants {
        static let barHeight: CGFloat = 9
        static let minInterval: TimeInterval = 300 // 5 minutes
        static let editorHeight: CGFloat = 80
        static let verticalPadding: CGFloat = 16
    }

    // MARK: - Dependencies

    let duration: TimeInterval
    @Binding var events: [FuelingEvent]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            intervalEditor
        }
    }
}

// MARK: - Private methods

private extension IntervalEventsTimelineEditor {
    var header: some View {
        Text(Localizables.RaceNutritionResults.intervalEventsTitle)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    var intervalEditor: some View {
        GeometryReader { geo in
            let usableWidth = max(1, geo.size.width)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: Constants.barHeight / 2)
                    .fill(Color(.lightGray).opacity(0.8))
                    .frame(height: Constants.barHeight)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .allowsHitTesting(false)
                    .zIndex(0)
                    .offset(y: -Constants.verticalPadding + 1)

                ForEach(events.indices, id: \.self) { index in
                    let event = events[index]
                    if case let .interval(start, end) = event.consumption {
                        IntervalEventView(
                            duration: duration,
                            usableWidth: usableWidth,
                            start: start,
                            end: end,
                            minInterval: Constants.minInterval,
                            label: event.carbItem.name
                        ) { newStart, newEnd in
                            events[index] = FuelingEvent(
                                consumption: .interval(start: newStart, end: newEnd),
                                carbItem: event.carbItem
                            )
                        }
                        .zIndex(1)
                    }
                }
            }
            .padding(.vertical, Constants.verticalPadding)
        }
        .frame(height: Constants.editorHeight)
    }
}

// MARK: - Preview

#Preview {
    PreviewWrapper()
        .padding()
}

private struct PreviewWrapper: View {
    var events: [FuelingEvent] {
        [
            .init(
                consumption: .interval(start: 0, end: 1800),
                carbItem: .init(id: "1", name: "Drink1", gramsOfCarbs: 30, type: .drink)
            ),
            .init(
                consumption: .interval(start: 1800, end: 3600),
                carbItem: .init(id: "2", name: "Drink2", gramsOfCarbs: 30, type: .drink)
            )
        ]
    }

    var body: some View {
        IntervalEventsTimelineEditor(
            duration: 3600,
            events: .constant(events)
        )
    }
}
