//
//  TriGuide
//

import SwiftUI

public enum PickerLabelOrientation {
    case horizontal
    case vertical
}

public struct PickerLabel<Icon: View>: View {
    let orientation: PickerLabelOrientation
    let title: String
    let value: String
    let icon: () -> Icon

    public init(
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

    public var body: some View {
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
                .lineLimit(1)
            Text(value)
                .font(.Custom.Regular.font3)
                .layoutPriority(1)
            Spacer()
            icon()
                .fixedSize()
        }
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2),
            innerHorizontalPadding: 8,
            innerVerticalPadding: 8
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
        .cardBackground(
            backgroundColor: Color(UIColor.lightGray).opacity(0.2),
            innerHorizontalPadding: 8,
            innerVerticalPadding: 8
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
