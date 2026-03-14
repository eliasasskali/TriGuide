//
// TriGuide 2025
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

struct CarbItemView: View {
    // MARK: - Dependencies

    let item: CarbItem
    let selectable: Bool
    let onQuantityChange: ((Double) -> Void)?

    // MARK: - Properties

    @State private var isExpanded: Bool = false
    @Binding var quantity: Int?

    // MARK: - Initializer

    init(
        item: CarbItem,
        quantity: Binding<Int?> = .constant(nil),
        selectable: Bool = false,
        onQuantityChange: ((Double) -> Void)? = nil,
    ) {
        self.item = item
        _quantity = quantity
        self.selectable = selectable
        self.onQuantityChange = onQuantityChange
    }

    // MARK: - Body

    var body: some View {
        itemView
            .cardBackground(
                innerHorizontalPadding: 16,
                innerVerticalPadding: isExpanded ? 16 : 8
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
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
            HStack {
                Image(systemName: item.type.systemIconName)
                    .font(.Custom.Regular.font2)
                    .foregroundStyle(item.type.tintColor)
                    .frame(width: 20)

                Text(Localizables.CarbItems.carbsValue(grams: item.gramsOfCarbs))
                    .font(.Custom.Regular.font2)

                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                }

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
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }

            if selectable {
                quantityPicker
            }
        }
    }

    @ViewBuilder
    var expandedItemView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                HStack {
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                    }

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
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }

                if selectable {
                    quantityPicker
                }
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

    @ViewBuilder
    var quantityPicker: some View {
        if quantity != nil {
            QuantityPickerView(
                quantity: Binding(
                    get: { quantity ?? 0 },
                    set: { quantity = $0 }
                ),
                onIncrementQuantity: { newQuantity in
                    onQuantityChange?(Double(newQuantity))
                },
                onDecrementQuantity: { newQuantity in
                    onQuantityChange?(Double(newQuantity))
                },
                orientation: .horizontal
            )
        } else {
            EmptyView()
        }
    }
}

// MARK: - Preview

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

    CarbItemView(
        item: CarbItem(
            id: "maurten-gel-100-caf-100",
            name: "Maurten Gel 100 Caf 100",
            gramsOfCarbs: 25,
            caffeine: 100,
            sodium: 55,
            waterVolumeML: 500,
            type: .gel,
            brand: "maurten",
            isFavorite: true
        ),
        quantity: .constant(0),
        selectable: true
    )
}

// MARK: - CarbType Appearance

private extension CarbType {
    var systemIconName: String {
        switch self {
        case .gel: "flame.fill"
        case .drink: "drop.fill"
        case .solid: "fork.knife"
        case .other: "circle.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .gel: .orange
        case .drink: .blue
        case .solid: .green
        case .other: .gray
        }
    }
}
