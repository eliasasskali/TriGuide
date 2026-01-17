//
// TriGuide 2026
//

import SwiftUI

struct InstantEventHandle: View {
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
                    
                    tempTime = clamp(
                        (dragStartTime! + deltaTime).roundedToNearest(minutes: 5)
                    )
                }
                .onEnded { _ in
                    let committed = clamp(
                        (tempTime ?? initialTime).roundedToNearest(minutes: 5)
                    )
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
