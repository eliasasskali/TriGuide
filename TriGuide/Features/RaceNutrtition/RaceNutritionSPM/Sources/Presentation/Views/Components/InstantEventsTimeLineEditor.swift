//
// TriGuide 2025
//

import SwiftUI
import TriGuideDomain

/// Timeline editor for instant fueling events.
/// Usage:
/// InstantEventsTimelineEditor(duration: result.duration, events: $editableInstantEvents)
struct InstantEventsTimelineEditor: View {
    let duration: TimeInterval
    @Binding var events: [FuelingEvent]

    private let barHeight: CGFloat = 8
    private let handleSize: CGFloat = 28
    private let bottomLabelSpacing: CGFloat = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            title
            itemsBar
        }
    }
}

// MARK: - Private helper
private extension InstantEventsTimelineEditor {

    // MARK: - Views

    var title: some View {
        Text("Instant fueling events")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    var itemsBar: some View {
        GeometryReader { geo in
            let fullWidth = max(1, geo.size.width)
            let usableWidth = max(1, fullWidth - handleSize)

            ZStack(alignment: .leading) {
                // Background bar centered vertically
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .frame(height: barHeight)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Handles for each instant event
                ForEach(Array(events.enumerated()), id: \.element.id) { (index, event) in
                    if case let .instant(time) = event.consumption {
                        // Circle (draggable) and time label positioned with offsets
                        InstantEventHandle(
                            duration: duration,
                            usableWidth: usableWidth,
                            initialTime: time,
                            label: event.carbItem.name
                        ) { newTime in
                            events[index] = FuelingEvent(
                                consumption: .instant(time: newTime),
                                carbItem: event.carbItem
                            )
                        }
                        .offset(y: handleSize + barHeight/2)
                    }
                }
            }
        }
    }

    // MARK: - Gesture helper

    func dragGesture(for index: Int, initialTime: TimeInterval, usableWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // Use translation to compute time delta; store a temporary event time in the events array
                // Start with the current (or previously temporary) time as base
                let baseTime = events[index].consumptionTimeOrZero // helper below
                let deltaFraction = Double(value.translation.width / usableWidth)
                let deltaTime = deltaFraction * duration
                let newTime = clampTime(TimeInterval(baseTime + deltaTime).roundedToMinute)
                // update a temporary visual time by replacing the event with a temp event
                var copy = events
                copy[index] = FuelingEvent(consumption: .instant(time: newTime), carbItem: events[index].carbItem)
                events = copy
            }
            .onEnded { value in
                // On end we already updated the events during onChanged; ensure final commit is clamped
                let baseTime = events[index].consumptionTimeOrZero
                // We can also compute from translation again to be safe:
                let deltaFraction = Double(value.translation.width / usableWidth)
                let deltaTime = deltaFraction * duration
                let committed = clampTime((baseTime + deltaTime).roundedToMinute)
                var copy = events
                copy[index] = FuelingEvent(consumption: .instant(time: committed), carbItem: events[index].carbItem)
                events = copy
            }
    }

    // MARK: - Helpers

    func timeToX(time: TimeInterval, usableWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        let clamped = clampTime(time)
        let fraction = CGFloat(clamped / duration)
        return (handleSize / 2) + fraction * usableWidth - (handleSize / 2)
        // simplified to fraction * usableWidth (usableWidth already accounts for handle padding)
        // but added anchor adjustments so handle edges don't overflow
    }

    func clampTime(_ t: TimeInterval) -> TimeInterval {
        min(max(0, t), duration)
    }
}

private struct InstantEventHandle: View {
    let duration: TimeInterval
    let usableWidth: CGFloat
    let initialTime: TimeInterval
    let label: String?
    let onCommit: (TimeInterval) -> Void

    @State private var dragStartTime: TimeInterval? = nil
    @State private var tempTime: TimeInterval? = nil

    private let handleSize: CGFloat = 28

    var body: some View {
        let displayTime: TimeInterval = (tempTime ?? initialTime).roundedToMinute
        let x = timeToX(displayTime)

        VStack(spacing: 8) {
            Circle()
                .strokeBorder(lineWidth: 2)
                .background(Circle().fill(Color(.systemBackground)))
                .frame(width: handleSize, height: handleSize)
                .shadow(radius: 1)

            Text(displayTime.formattedAsHourMin)
                .font(.Custom.Regular.font2)
                .fixedSize()

            if let label {
                Text(label)
                    .font(.Custom.Regular.font1)
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 35)
                    .rotationEffect(.degrees(90))
            }
        }
        .offset(x: x)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if dragStartTime == nil {
                        dragStartTime = initialTime
                    }

                    let deltaTime = (value.translation.width / usableWidth) * duration

                    tempTime = clamp((dragStartTime! + deltaTime).roundedToMinute)
                }
                .onEnded { _ in
                    let committed = clamp((tempTime ?? initialTime).roundedToMinute)
                    onCommit(committed)

                    dragStartTime = nil
                    tempTime = nil
                }
        )
    }

    // MARK: - Helpers

    private func timeToX(_ time: TimeInterval) -> CGFloat {
        guard duration > 0 else { return 0 }
        let fraction = CGFloat(time / duration)
        return fraction * usableWidth
    }

    private func clamp(_ time: TimeInterval) -> TimeInterval {
        min(max(0, time), duration)
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var fuelingEvents: [FuelingEvent]

    private let duration: TimeInterval = 3600

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
            .init(consumption: .instant(time: 1800), carbItem: item2),
            .init(consumption: .instant(time: 3000), carbItem: item)
        ])
    }

    var body: some View {
        InstantEventsTimelineEditor(
            duration: 3600,
            events: $fuelingEvents
        )
    }
}

