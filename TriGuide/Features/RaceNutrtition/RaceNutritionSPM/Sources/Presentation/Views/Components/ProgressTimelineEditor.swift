import SwiftUI
import TriGuideDomain

/// Editable local representation of an event
private struct EditableEvent: Identifiable {
    let id = UUID()
    var item: CarbItem
    var isInterval: Bool
    var start: TimeInterval // for instant: center time
    var end: TimeInterval   // for instant: same as start
}

/// Main editor view — now shows TWO bars (instants on top, intervals on bottom)
public struct ProgressTimelineEditor: View {
    @Binding var fuelingResult: TriGuideDomain.FuelingResult

    // Local editable copy
    @State private var editEvents: [EditableEvent] = []
    @State private var duration: TimeInterval = 1.0

    // UI constants
    private let minIntervalSeconds: TimeInterval = 5.0 // prevent zero-length intervals
    private let circleSize: CGFloat = 24
    private let labelFont = Font.system(size: 11)

    // Layout tuning
    private let topBarHeight: CGFloat = 120
    private let bottomBarHeight: CGFloat = 120
    private let barCapsuleHeight: CGFloat = 12
    private let barHorizontalPadding: CGFloat = 8

    public init(
        fuelingResult: Binding<TriGuideDomain.FuelingResult>,
        barHeight: CGFloat = 12,
        handleSize: CGFloat = 14
    ) {
        self._fuelingResult = fuelingResult
    }

    public var body: some View {
        VStack(spacing: 12) {
            // TOP: Instant events bar (labels above markers)
            GeometryReader { geo in
                ZStack {
                    // axis/backdrop
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor.secondarySystemFill))
                        .frame(height: barCapsuleHeight)
                        .position(x: geo.size.width / 2.0, y: geo.size.height / 2.0)

                    // instant markers + labels
                    ForEach(editEvents) { ee in
                        if !ee.isInterval {
                            let x = xPosition(forTime: ee.start, totalWidth: geo.size.width)
                            VStack(spacing: 6) {
                                // label above circle
                                Text(ee.item.name)
                                    .font(labelFont)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .fixedSize()
                                    .frame(width: 80)

                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: circleSize, height: circleSize)
                                    .shadow(radius: 1)
                                    .gesture(dragInstantGesture(eventID: ee.id, width: geo.size.width))
                            }
                            .position(x: x, y: geo.size.height / 2.0)
                        }
                    }
                }
                .onAppear {
                    loadEditEvents()
                    duration = fuelingResult.duration
                }
            }
            .frame(height: topBarHeight)

            // BOTTOM: Interval events bar (labels below bars)
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor.secondarySystemFill))
                        .frame(height: barCapsuleHeight)
                        .position(x: geo.size.width / 2.0, y: geo.size.height / 2.0)

                    ForEach(editEvents) { ee in
                        if ee.isInterval {
                            let xStart = xPosition(forTime: ee.start, totalWidth: geo.size.width)
                            let xEnd = xPosition(forTime: ee.end, totalWidth: geo.size.width)
                            let width = max(2, xEnd - xStart)

                            // filled interval
                            Rectangle()
                                .fill(Color.blue.opacity(0.32))
                                .frame(width: width, height: barCapsuleHeight)
                                .position(x: xStart + width / 2.0, y: geo.size.height / 2.0)

                            // handles
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: 14, height: 14)
                                .position(x: xStart, y: geo.size.height / 2.0)
                                .gesture(dragIntervalHandleGesture(eventID: ee.id, isStart: true, width: geo.size.width))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: 14, height: 14)
                                .position(x: xEnd, y: geo.size.height / 2.0)
                                .gesture(dragIntervalHandleGesture(eventID: ee.id, isStart: false, width: geo.size.width))

                            // label below the bar (bottom-aligned)
                            Text(ee.item.name)
                                .font(labelFont)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .fixedSize()
                                .frame(width: max(80, width))
                                .position(x: xStart + width / 2.0, y: (geo.size.height / 2.0) + barCapsuleHeight/2 + 18)
                        }
                    }
                }
            }
            .frame(height: bottomBarHeight)

            // Controls (single reset / apply apply to both bars)
            HStack(spacing: 12) {
                Button("Reset") {
                    loadEditEvents()
                }
                .buttonStyle(.bordered)

                Button("Apply changes") {
                    applyChangesToBinding()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onChange(of: fuelingResult) { _ in
            // update local when external changes happen
            loadEditEvents()
        }
    }

    // MARK: - Helpers: coordinate math

    private func xPosition(forTime time: TimeInterval, totalWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        let frac = CGFloat(max(0.0, min(1.0, time / duration)))
        return frac * totalWidth
    }

    private func timeFrom(x: CGFloat, width: CGFloat) -> TimeInterval {
        guard width > 0 else { return 0 }
        let frac = Double(max(0.0, min(1.0, Double(x / width))))
        return frac * duration
    }

    // MARK: - Gestures

    private func dragInstantGesture(eventID: UUID, width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                guard let idx = editEvents.firstIndex(where: { $0.id == eventID }) else { return }
                let newTime = timeFrom(x: value.location.x, width: width)
                // clamp to duration
                editEvents[idx].start = min(max(0.0, newTime), duration)
                editEvents[idx].end = editEvents[idx].start
            }
            .onEnded { _ in /* nothing extra */ }
    }

    private func dragIntervalHandleGesture(eventID: UUID, isStart: Bool, width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                guard let idx = editEvents.firstIndex(where: { $0.id == eventID }) else { return }
                let newTime = timeFrom(x: value.location.x, width: width)
                if isStart {
                    // ensure start <= end - minIntervalSeconds
                    let maxStart = editEvents[idx].end - minIntervalSeconds
                    let clamped = min(max(0.0, newTime), maxStart)
                    editEvents[idx].start = clamped
                } else {
                    // ensure end >= start + minIntervalSeconds
                    let minEnd = editEvents[idx].start + minIntervalSeconds
                    let clamped = max(min(duration, newTime), minEnd)
                    editEvents[idx].end = clamped
                }
            }
            .onEnded { _ in /* nothing extra */ }
    }

    // MARK: - Load / apply

    private func loadEditEvents() {
        duration = fuelingResult.duration
        editEvents = fuelingResult.timeLine.map { ev in
            switch ev.consumption {
            case .instant(let t):
                return EditableEvent(item: ev.carbItem, isInterval: false, start: t, end: t)
            case .interval(let s, let e):
                return EditableEvent(item: ev.carbItem, isInterval: true, start: s, end: e)
            }
        }
    }

    private func applyChangesToBinding() {
        // convert editEvents back to FuelingEvent array
        let newEvents = editEvents.map { ee -> TriGuideDomain.FuelingEvent in
            if ee.isInterval {
                return TriGuideDomain.FuelingEvent(consumption: .interval(start: ee.start, end: ee.end), carbItem: ee.item)
            } else {
                return TriGuideDomain.FuelingEvent(consumption: .instant(time: ee.start), carbItem: ee.item)
            }
        }
        // assign sorted timeline so UI consumers keep consistent order
        let sorted = newEvents.sorted { a, b in
            func startTime(of ev: TriGuideDomain.FuelingEvent) -> TimeInterval {
                switch ev.consumption {
                case .instant(let t): return t
                case .interval(let s, _): return s
                }
            }
            return startTime(of: a) < startTime(of: b)
        }

        fuelingResult = TriGuideDomain.FuelingResult(
            name: fuelingResult.name,
            timeLine: sorted,
            totalCarbsTarget: fuelingResult.totalCarbsTarget,
            duration: fuelingResult.duration,
            selectedItems: fuelingResult.selectedItems,
            hourlyBreakdown: fuelingResult.hourlyBreakdown
        )
    }
}
