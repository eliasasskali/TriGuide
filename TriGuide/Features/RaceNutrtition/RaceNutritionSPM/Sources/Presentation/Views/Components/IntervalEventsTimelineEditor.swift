//
// TriGuide 2026
//

import TriGuideDomain
import SwiftUI

struct IntervalEventsTimelineEditor: View {
    let duration: TimeInterval
    @Binding var events: [FuelingEvent]

    private let barHeight: CGFloat = 8
    private let handleSize: CGFloat = 20
    private let minInterval: TimeInterval = 300 // 5 minutes

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Drink intake")
                .font(.subheadline)
                .foregroundColor(.secondary)

            GeometryReader { geo in
                let usableWidth = max(1, geo.size.width)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(Color(.lightGray).opacity(0.3))
                        .frame(height: barHeight)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .allowsHitTesting(false)
                        .zIndex(0)
                        .offset(y: -17)

                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        if case let .interval(start, end) = event.consumption {
                            IntervalEventView(
                                duration: duration,
                                usableWidth: usableWidth,
                                start: start,
                                end: end,
                                minInterval: minInterval,
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
                .padding(.vertical)
            }
            .frame(height: 80)
        }
    }
}

private struct IntervalEventView: View {
    let duration: TimeInterval
    let usableWidth: CGFloat
    let start: TimeInterval
    let end: TimeInterval
    let minInterval: TimeInterval
    let label: String?
    let onCommit: (TimeInterval, TimeInterval) -> Void

    // Cached origins for gestures
    @State private var dragStart: (start: TimeInterval, end: TimeInterval)?
    @State private var startHandleOrigin: TimeInterval? = nil
    @State private var endHandleOrigin: TimeInterval? = nil

    // Temp editing values while dragging
    @State private var tempStart: TimeInterval?
    @State private var tempEnd: TimeInterval?

    private let handleSize: CGFloat = 20
    private let barHeight: CGFloat = 12

    var body: some View {
        let startTime = tempStart ?? start
        let endTime = tempEnd ?? end

        let xStart = x(for: startTime)
        let xEnd = x(for: endTime)
        let width = max(4, xEnd - xStart)

        VStack(spacing: 6) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: width, height: barHeight)

                Circle()
                    .fill(Color.blue)
                    .frame(width: handleSize, height: handleSize)
                    .offset(x: 0)
                    .highPriorityGesture(startHandleGesture)

                Circle()
                    .fill(Color.blue)
                    .frame(width: handleSize, height: handleSize)
                    .offset(x: width - handleSize)
                    .highPriorityGesture(endHandleGesture)
            }

            Text("\(startTime.roundedToNearest(minutes: 5).formattedAsHourMin) - \(endTime.roundedToNearest(minutes: 5).formattedAsHourMin)")
                .font(.Custom.Regular.font1)
                .frame(width: max(60, width), alignment: .center)
                .multilineTextAlignment(.center)

            if let label {
                Text(label)
                    .font(.Custom.Regular.font1)
                    .frame(width: max(60, width), alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, xStart)
        .gesture(intervalDragGesture) // whole-interval drag
    }

    // MARK: - Gestures

    private var intervalDragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                // capture origins on first movement
                if dragStart == nil {
                    dragStart = (start, end)
                }

                let delta = timeDelta(from: value.translation.width)
                let newStart = clamp(dragStart!.start + delta)
                let newEnd = clamp(dragStart!.end + delta)

                // Snap to nearest 5-minute during drag
                let snappedStart = newStart
                let snappedEnd = newEnd

                // enforce minimum length
                if snappedEnd - snappedStart >= minInterval {
                    tempStart = snappedStart
                    tempEnd = snappedEnd
                } else {
                    // fallback: ensure at least minInterval by moving end
                    let fallbackEnd = snappedStart + minInterval
                    if fallbackEnd <= duration {
                        tempStart = snappedStart
                        tempEnd = fallbackEnd
                    }
                }
            }
            .onEnded { _ in
                commit()
            }
    }

    private var startHandleGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if startHandleOrigin == nil {
                    startHandleOrigin = tempStart ?? start
                }

                // Move relative to the starting origin using translation
                let delta = timeDelta(from: value.translation.width)
                var newStart = clamp(startHandleOrigin! + delta)

                // ensure we don't collapse below minInterval vs current end (tempEnd takes precedence)
                let endForCheck = tempEnd ?? end
                let maxStart = endForCheck - minInterval
                if newStart > maxStart {
                    newStart = maxStart
                }

                tempStart = newStart
            }
            .onEnded { _ in
                startHandleOrigin = nil
                commit()
            }
    }

    private var endHandleGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if endHandleOrigin == nil {
                    endHandleOrigin = tempEnd ?? end
                }

                let delta = timeDelta(from: value.translation.width)
                var newEnd = clamp(endHandleOrigin! + delta)

                // ensure min length vs current start
                let startForCheck = tempStart ?? start
                let minEnd = startForCheck + minInterval
                if newEnd < minEnd {
                    newEnd = minEnd
                }

                tempEnd = newEnd
            }
            .onEnded { _ in
                endHandleOrigin = nil
                commit()
            }
    }

    // MARK: - Helpers

    private func commit() {
        // Round both to nearest 5 minutes on commit
        var finalStart = (tempStart ?? start).roundedToNearest(minutes: 5)
        var finalEnd = (tempEnd ?? end).roundedToNearest(minutes: 5)
        // ensure min length after rounding
        if finalEnd - finalStart < minInterval {
            finalEnd = min(duration, finalStart + minInterval)
            finalStart = max(0, finalEnd - minInterval)
            // re-round to 5-min boundary (ensure multiples)
            finalStart = finalStart.roundedToNearest(minutes: 5)
            finalEnd = finalEnd.roundedToNearest(minutes: 5)
        }

        onCommit(finalStart, finalEnd)

        // clear temp state
        dragStart = nil
        tempStart = nil
        tempEnd = nil
    }

    private func x(for time: TimeInterval) -> CGFloat {
        guard duration > 0 else { return 0 }
        return CGFloat(max(0.0, min(1.0, time / duration))) * usableWidth
    }

    private func timeFrom(x: CGFloat) -> TimeInterval {
        clamp(TimeInterval(x / usableWidth) * duration)
    }

    private func timeDelta(from dx: CGFloat) -> TimeInterval {
        TimeInterval(dx / usableWidth) * duration
    }

    private func clamp(_ t: TimeInterval) -> TimeInterval {
        min(max(0, t), duration)
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
