//
// TriGuide 2025
//

import SwiftUI

public struct ProgressBarView: View {
    let progress: Double

    public init(progress: Double) {
        self.progress = progress
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(height: 12)
                    .foregroundColor(Color(UIColor.lightGray).opacity(0.3))

                RoundedRectangle(cornerRadius: 8)
                    .frame(width: geometry.size.width * CGFloat(min(progress, 1)), height: 12)
                    .foregroundColor(.blue)
                    .animation(.linear, value: progress)
            }
        }
        .frame(height: 16)
    }
}

#Preview {
    ProgressBarView(progress: 0.6)
}
