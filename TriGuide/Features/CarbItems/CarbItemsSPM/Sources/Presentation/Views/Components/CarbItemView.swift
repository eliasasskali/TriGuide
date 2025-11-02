//
// TriGuide 2025
//

import SwiftUI
import Localization

struct CarbItemView: View {
    let item: CarbItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                Text(item.name)
                    .font(.Custom.Medium.font3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let brand = item.brand, !brand.isEmpty {
                    Text(brand.capitalizingFirstLetter())
                        .font(.Custom.Regular.font2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()
                    .background(Color(.separator))
                    .padding(.vertical, 8)
            }

            HStack(spacing: 8) {
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

                Spacer()
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardBackground(innerPadding: 16)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Private methods

private extension CarbItemView {
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
