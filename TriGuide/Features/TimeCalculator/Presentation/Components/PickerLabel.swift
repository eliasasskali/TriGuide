//
//  TriGuide
//

import SwiftUI

enum PickerLabelOrientation {
    case horizontal
    case vertical
}

struct PickerLabel<Icon: View>: View {
    let orientation: PickerLabelOrientation
    let title: String
    let value: String
    let icon: () -> Icon

    init(
        orientation: PickerLabelOrientation,
        title: String,
        value: String,
        @ViewBuilder icon: @escaping () -> Icon = { EmptyView() }
    ) {
        self.orientation = orientation
        self.title = title
        self.value = value
        self.icon = icon
    }

    var body: some View {
        switch orientation {
        case .horizontal:
            horizontalPickerLabel
        case .vertical:
            verticalPickerLabel
        }
    }
}

private extension PickerLabel {
    var horizontalPickerLabel: some View {
        HStack(alignment: .center) {
            Text(title)
                .foregroundStyle(.black)
                .font(.Custom.Medium.font3)
            Text(value)
                .font(.Custom.Regular.font3)
            Spacer()
            icon()
        }
        .padding(8)
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2)
        )
    }
    var verticalPickerLabel: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundStyle(.black)
                    .font(.Custom.Medium.font3)
                Text(value)
                    .font(.Custom.Regular.font3)
            }
            Spacer()
            icon()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2)
        )
    }
}

#Preview {
    PickerLabel(
        orientation: .horizontal,
        title: "Time:",
        value: "1:45"
    ) {
        Image(systemName: "chevron.down")
            .font(.Custom.Regular.font4)
    }
}
