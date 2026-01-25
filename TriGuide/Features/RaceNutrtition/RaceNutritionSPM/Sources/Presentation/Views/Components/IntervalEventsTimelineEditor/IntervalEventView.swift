//
// TriGuide 2026
//

import SwiftUI

struct IntervalEventView: View {

    // MARK: - Constants

    enum Constants {
        static let handleSize: CGFloat = 20
        static let barHeight: CGFloat = 12
    }

    // MARK: - Dependencies

    let duration: TimeInterval
    let usableWidth: CGFloat
    let start: TimeInterval
    let end: TimeInterval
    let minInterval: TimeInterval
    let label: String?
    let onCommit: (TimeInterval, TimeInterval) -> Void

    // MARK: - Properties

    @State private var dragStart: (start: TimeInterval, end: TimeInterval)?
    @State private var startHandleOrigin: TimeInterval? = nil
    @State private var endHandleOrigin: TimeInterval? = nil
    @State private var tempStart: TimeInterval?
    @State private var tempEnd: TimeInterval?

    // MARK: - Computed properties

    var startTime: TimeInterval {
        tempStart ?? start
    }

    var endTime: TimeInterval {
        tempEnd ?? end
    }

    var xStart: CGFloat {
        x(for: startTime)
    }

    var width: CGFloat {
        let xEnd = x(for: endTime)

        return max(4, xEnd - xStart)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 6) {
            intervalBar
                .frame(height: Constants.barHeight)
            intervalLabel
        }
        .offset(x: xStart)
        .gesture(intervalDragGesture)
    }
}

// MARK: - Private methods

private extension IntervalEventView {

    var intervalBar: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Constants.barHeight / 2)
                .fill(Color.blue.opacity(0.7))
                .frame(height: Constants.barHeight)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    HStack(spacing: 0) {
                        handle
                            .highPriorityGesture(startHandleGesture)
                        Spacer()
                        handle
                            .highPriorityGesture(endHandleGesture)
                    }
                }
        }
        .frame(width: width)
    }

    var handle: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: Constants.handleSize, height: Constants.handleSize)
    }

    var intervalLabel: some View {
        let intervalTimeText = "\(startTime.roundedToNearest(minutes: 5).formattedAsHourMin) - \(endTime.roundedToNearest(minutes: 5).formattedAsHourMin)"

        return VStack {
            Text(intervalTimeText)
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
    }

    // MARK: - Gestures

    var intervalDragGesture: some Gesture {
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

    var startHandleGesture: some Gesture {
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

    var endHandleGesture: some Gesture {
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

    func commit() {
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

    func x(for time: TimeInterval) -> CGFloat {
        guard duration > 0 else { return 0 }
        return CGFloat(max(0.0, min(1.0, time / duration))) * usableWidth
    }

    func timeFrom(x: CGFloat) -> TimeInterval {
        clamp(TimeInterval(x / usableWidth) * duration)
    }

    func timeDelta(from dx: CGFloat) -> TimeInterval {
        TimeInterval(dx / usableWidth) * duration
    }

    func clamp(_ t: TimeInterval) -> TimeInterval {
        min(max(0, t), duration)
    }
}

// MARK: - Preview

#Preview {
    IntervalEventView(
        duration: 600,
        usableWidth: UIScreen.main.bounds.width,
        start: 0,
        end: 300,
        minInterval: 300,
        label: "Carb item"
    ) { _, _ in }
}
