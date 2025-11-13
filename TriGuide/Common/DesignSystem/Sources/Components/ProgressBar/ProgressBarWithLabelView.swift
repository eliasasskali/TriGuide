//
// TriGuide 2025
//

import SwiftUI

public struct ProgressBarWithLabelView: View {
    let label: String
    let value: String
    let progress: Double

    public init(
        label: String,
        value: String,
        progress: Double
    ) {
        self.label = label
        self.value = value
        self.progress = progress
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.Custom.Medium.font3)

                Text(value)
                    .font(.Custom.Regular.font3)
            }
            ProgressBarView(progress: progress)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ProgressBarWithLabelView(
        label: "Carbohydrates:",
        value: "150 / 300 g",
        progress: 0.5
    )
}
