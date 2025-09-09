//
//  TriGuide 2025
//

import SwiftUI

struct TotalTimeView: View {
    let time: String

    var body: some View {
        HStack(spacing: 0) {
            Text(String("\(Localizables.PaceCalculator.totalTime): "))
                .font(.Custom.Medium.font5)
            Text(time)
                .font(.Custom.Regular.font5)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2)
        )
    }
}

#Preview {
    TotalTimeView(
        time: "1:23:45"
    )
}
