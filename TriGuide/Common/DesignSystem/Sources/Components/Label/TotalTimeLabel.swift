//
//  TriGuide 2025
//

import SwiftUI
import Localization

public struct TotalTimeLabel: View {
    let time: String

    public init(time: String) {
        self.time = time
    }

    public var body: some View {
        HStack(spacing: 0) {
            Text(String("\(Localizables.PaceCalculator.totalTime): "))
                .font(.Custom.Medium.font5)
            Text(time)
                .font(.Custom.Regular.font5)
        }
        .frame(maxWidth: .infinity)
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2),
            innerPadding: 8
        )
    }
}

#Preview {
    TotalTimeLabel(
        time: "1:23:45"
    )
}
