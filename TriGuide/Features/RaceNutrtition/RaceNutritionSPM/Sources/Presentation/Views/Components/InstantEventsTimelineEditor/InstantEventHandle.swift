//
// TriGuide 2026
//

import SwiftUI

struct InstantEventHandle: View {

    // MARK: - Constants

    enum Constants {
        static let handleSize: CGFloat = 28
        static let labelHeight: CGFloat = 50
        static let verticalSpacing: CGFloat = 8
        static let timeLabelHeight: CGFloat = 20
    }

    // MARK: - Dependencies

    let duration: TimeInterval
    let usableWidth: CGFloat
    let initialTime: TimeInterval
    let label: String?
    let textGoesAbove: Bool
    let onCommit: (TimeInterval) -> Void

    // MARK: - Properties

    @State private var dragStartTime: TimeInterval? = nil
    @State private var tempTime: TimeInterval? = nil

    // MARK: - Computed properties

    var displayTime: TimeInterval {
        (tempTime ?? initialTime).roundedToMinute
    }

    // MARK: - Initializer

    init(
        duration: TimeInterval,
        usableWidth: CGFloat,
        initialTime: TimeInterval,
        label: String?,
        textGoesAbove: Bool = false,
        onCommit: @escaping (TimeInterval) -> Void
    ) {
        self.duration = duration
        self.usableWidth = usableWidth
        self.initialTime = initialTime
        self.label = label
        self.textGoesAbove = textGoesAbove
        self.onCommit = onCommit
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Constants.verticalSpacing) {
            if textGoesAbove {
                VStack(spacing: Constants.verticalSpacing) {
                    textLabel
                    timeLabel
                }
            }

            circleHandle

            if !textGoesAbove {
                timeLabel
                textLabel
            }
        }
        .offset(x: timeToX(displayTime))
        .animation(.interactiveSpring(), value: displayTime)
        .animation(.easeInOut(duration: 0.2), value: textGoesAbove)
        .gesture(dragGesture)
    }
}

// MARK: - Private methods

private extension InstantEventHandle {

    @ViewBuilder
    var textLabel: some View {
        if let label {
            Text(label)
                .font(.Custom.Regular.font1)
                .multilineTextAlignment(.center)
                .frame(width: 35, height: 50)
                .minimumScaleFactor(0.8)
                .rotationEffect(.degrees(90))
                .lineLimit(3)
                .frame(height: Constants.labelHeight)
        }
    }

    var timeLabel: some View {
        Text(displayTime.formattedAsHourMin)
            .font(.Custom.Regular.font2)
            .fixedSize()
            .frame(height: Constants.timeLabelHeight)
    }

    var circleHandle: some View {
        Circle()
            .fill(Color(.systemBackground))
            .frame(width: Constants.handleSize, height: Constants.handleSize)
            .overlay(
                Circle().stroke(Color.blue, lineWidth: 5)
            )
            .padding(.bottom, Constants.verticalSpacing)
    }

    // MARK: - Gestures

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStartTime == nil {
                    dragStartTime = tempTime ?? initialTime
                }

                let deltaTime = (value.translation.width / usableWidth) * duration

                withAnimation(.interactiveSpring()) {
                    tempTime = clamp(
                        (dragStartTime! + deltaTime).roundedToNearest(minutes: 5)
                    )
                }
            }
            .onEnded { _ in
                let committed = clamp(
                    (tempTime ?? initialTime).roundedToNearest(minutes: 5)
                )
                onCommit(committed)

                dragStartTime = nil
                tempTime = nil
            }
    }

    // MARK: - Helpers

    func timeToX(_ time: TimeInterval) -> CGFloat {
        guard duration > 0 else { return 0 }
        let fraction = CGFloat(time / duration)
        return fraction * usableWidth
    }

    func clamp(_ time: TimeInterval) -> TimeInterval {
        min(max(0, time), duration)
    }
}

// MARK: - Expose handle height

extension InstantEventHandle {
    static var totalHeight: CGFloat {
        Constants.handleSize + Constants.labelHeight + Constants.timeLabelHeight + Constants.verticalSpacing * 3
    }
}

// MARK: - Preview

#Preview {
    InstantEventHandle(
        duration: 600,
        usableWidth: UIScreen.main.bounds.width,
        initialTime: 0,
        label: "Instant item",
        textGoesAbove: true,
        onCommit: { _ in }
    )
}
