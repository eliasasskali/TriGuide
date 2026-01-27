//
// TriGuide 2025
//

import Localization
import SwiftUI
import TriGuideDomain

struct InstantEventsTimelineEditor: View {
    // MARK: - Constants

    enum Constants {
        static let handleSize: CGFloat = 28
        static let barHeight: CGFloat = 8
        static let barVerticalOffset: CGFloat = 2
        static let handleVerticalOffset: CGFloat = 6
    }

    // MARK: - Dependencies

    let duration: TimeInterval
    @Binding var events: [FuelingEvent]

    // MARK: - Computed properties

    private var belowTextHandleY: CGFloat {
        InstantEventHandle.totalHeight + Constants.barHeight / 2 - Constants.handleSize / 2 - Constants.handleVerticalOffset
    }

    private var aboveTextHandleY: CGFloat {
        Constants.handleVerticalOffset + Constants.handleSize / 2
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            title
            instantsEditor
        }
    }
}

// MARK: - Private methods

private extension InstantEventsTimelineEditor {
    // MARK: - Views

    var title: some View {
        Text(Localizables.RaceNutritionResults.instantEventsTitle)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    var instantsEditor: some View {
        GeometryReader { geo in
            let usableWidth = max(1, max(1, geo.size.width) - Constants.handleSize)
            let barY = InstantEventHandle.totalHeight - Constants.barHeight / 2 - Constants.barVerticalOffset

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Constants.barHeight / 2)
                    .fill(Color(.lightGray).opacity(0.6))
                    .frame(height: Constants.barHeight)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .offset(y: barY)
                    .allowsHitTesting(false)

                eventHandles(usableWidth: usableWidth)
            }
        }
        .frame(height: 2 * InstantEventHandle.totalHeight)
        .padding(.trailing, Constants.handleSize / 2)
    }
}

// MARK: - Private methods

private extension InstantEventsTimelineEditor {
    func eventHandles(usableWidth: CGFloat) -> some View {
        // how many seconds the handle occupies on the timeline + 8 buffer
        let handleTime = TimeInterval((Constants.handleSize + 8) / usableWidth) * duration

        let instantEvents = events.enumerated().compactMap { index, event -> (Int, FuelingEvent)? in
            if case .instant = event.consumption { return (index, event) }
            return nil
        }

        return ForEach(instantEvents, id: \.0) { index, event in
            let time = event.consumptionTimeOrZero
            let textGoesAbove = events.indices.contains { otherIndex in
                guard otherIndex < index, // only check handles to the left
                      case let .instant(otherTime) = events[otherIndex].consumption
                else { return false }
                return abs(otherTime - time) <= handleTime
            }

            InstantEventHandle(
                duration: duration,
                usableWidth: usableWidth,
                initialTime: time,
                label: event.carbItem.name,
                textGoesAbove: textGoesAbove
            ) { newTime in
                events[index] = FuelingEvent(
                    consumption: .instant(time: newTime),
                    carbItem: event.carbItem
                )
            }
            .offset(y: textGoesAbove ? aboveTextHandleY : belowTextHandleY)
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewWrapper()
        .padding()
}

private struct PreviewWrapper: View {
    @State private var fuelingEvents: [FuelingEvent]

    init() {
        let item = CarbItem(
            id: "maurten-gel-100-caf-100",
            name: "Maurten Gel 100 Caf 100",
            gramsOfCarbs: 25,
            caffeine: 100,
            sodium: 55,
            waterVolumeML: 500,
            type: .gel,
            brand: "maurten"
        )

        let item2 = CarbItem(
            id: "maurten-gel-100-caf-100",
            name: "Maurten Gel 100",
            gramsOfCarbs: 25,
            caffeine: 100,
            sodium: 55,
            waterVolumeML: 500,
            type: .gel,
            brand: "maurten"
        )

        _fuelingEvents = State(initialValue: [
            .init(consumption: .instant(time: 600), carbItem: item),
            .init(consumption: .instant(time: 600), carbItem: item2),
            .init(consumption: .instant(time: 3000), carbItem: item),
        ])
    }

    var body: some View {
        InstantEventsTimelineEditor(
            duration: 3600,
            events: $fuelingEvents
        )
    }
}
