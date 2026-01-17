//
// TriGuide 2026
//

import TriGuideDomain
import SwiftUI
import Localization

struct IntervalEventsTimelineEditor: View {
    let duration: TimeInterval
    @Binding var events: [FuelingEvent]
    
    private let barHeight: CGFloat = 8
    private let handleSize: CGFloat = 20
    private let minInterval: TimeInterval = 300 // 5 minutes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Localizables.RaceNutritionResults.intervalEventsTitle)
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
