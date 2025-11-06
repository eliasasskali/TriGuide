//
// TriGuide 2025
//

import SwiftUI
import Localization

struct CarbItemView: View {
    let item: CarbItem

    @State private var isExpanded: Bool = false

    var body: some View {
        itemView
            .cardBackground(
                innerHorizontalPadding: 16,
                innerVerticalPadding: isExpanded ? 16 : 8
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
    }
}

// MARK: - Private methods

private extension CarbItemView {
    @ViewBuilder
    var itemView: some View {
        if isExpanded {
            expandedItemView
        } else {
            collapsedItemView
        }
    }

    @ViewBuilder
    var collapsedItemView: some View {
        HStack {
            Text(Localizables.CarbItems.carbsValue(grams: item.gramsOfCarbs))
                .font(.Custom.Regular.font2)

            // TODO: use start.fill for favs
//            Image(systemName: "bolt.fill")
//                .foregroundColor(.yellow)

            Divider()

            VStack(spacing: 0) {
                Text(item.name)
                    .font(.Custom.Medium.font3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let brand = item.brand, !brand.isEmpty {
                    Text(brand.capitalizingFirstLetter())
                        .font(.Custom.Regular.font2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()

            Image(systemName: "chevron.down")
        }
    }

    @ViewBuilder
    var expandedItemView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                VStack(spacing: 0) {
                    Text(item.name)
                        .font(.Custom.Medium.font3)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let brand = item.brand, !brand.isEmpty {
                        Text(brand.capitalizingFirstLetter())
                            .font(.Custom.Regular.font2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()

                Image(systemName: "chevron.up")
            }

            Divider()
                .background(Color(.separator))
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 8) {
                infoCell(
                    label: Localizables.CarbItems.carbsLabel,
                    value: Localizables.CarbItems.carbsValue(grams: item.gramsOfCarbs),
                    systemImageName: "bolt.fill",
                    imageColor: .yellow
                )

                if let caffeine = item.caffeine, caffeine > 0 {
                    Divider()
                    infoCell(
                        label: Localizables.CarbItems.caffeineLabel,
                        value: Localizables.CarbItems.caffeineValue(caffeine: caffeine),
                        systemImageName: "cup.and.saucer.fill",
                        imageColor: .brown
                    )
                }

                if let waterVolume = item.waterVolumeML, waterVolume > 0 {
                    Divider()
                    infoCell(
                        label: Localizables.CarbItems.volumeLabel,
                        value: Localizables.CarbItems.volumeValue(miliLiters: waterVolume),
                        systemImageName: "drop.fill",
                        imageColor: .blue
                    )
                }

                if let sodium = item.sodium, sodium > 0 {
                    Divider()
                    infoCell(
                        label: Localizables.CarbItems.sodiumLabel,
                        value: Localizables.CarbItems.sodiumValue(miliGrams: sodium),
                        systemImageName: "pill",
                        imageColor: .gray
                    )
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func infoCell(
        label: String,
        value: String,
        systemImageName: String,
        imageColor: Color
    ) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImageName)
                .foregroundColor(imageColor)
                .frame(width: 25, alignment: .center)
            Text(label)
                .font(.Custom.Medium.font2)
            Text(value)
                .font(.Custom.Regular.font2)
        }
        .fixedSize()
    }

    func formattedValue(_ value: Double) -> String {
        value.formattedAsDecimal(minFractionDigits: 0, maxFractionDigits: 2)
    }
}

#Preview {
    CarbItemView(
        item: CarbItem(
            id: "maurten-gel-100-caf-100",
            name: "Maurten Gel 100 Caf 100",
            gramsOfCarbs: 25,
            caffeine: 100,
            sodium: 55,
            waterVolumeML: 500,
            type: .gel,
            brand: "maurten"
        )
    )
}
