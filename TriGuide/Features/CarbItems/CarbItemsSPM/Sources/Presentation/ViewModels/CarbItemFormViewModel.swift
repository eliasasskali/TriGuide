//
// TriGuide 2025
//

import FormKit
import Foundation
import Localization
import TriGuideDomain

@MainActor
public final class CarbItemFormViewModel: ObservableObject {
    let sections: [FormSection]
    private let existingItem: CarbItem?
    private let saveAction: (CarbItem) -> Void

    public static let defaultSections: [FormSection] = [
        FormSection(
            title: Localizables.CarbItemForm.sectionTitleGeneralInformation,
            fields: [
                FieldDescriptor(
                    id: "name",
                    label: Localizables.CarbItemForm.labelProductName,
                    placeholder: Localizables.CarbItemForm.placeholderProductName,
                    type: .text,
                    required: true
                ),
                FieldDescriptor(
                    id: "brand",
                    label: Localizables.CarbItemForm.labelBrand,
                    placeholder: Localizables.CarbItemForm.placeholderBrand,
                    type: .text
                ),
                FieldDescriptor(
                    id: "type",
                    label: Localizables.CarbItemForm.labelCarbType,
                    type: .picker,
                    required: true,
                    options: CarbType.allCases.map {
                        FieldPickerOption(
                            id: $0.rawValue,
                            label: $0.rawValue.capitalized
                        )
                    }
                ),
            ]
        ),
        FormSection(
            title: Localizables.CarbItemForm.sectionTitleNutritionalInformation,
            fields: [
                FieldDescriptor(
                    id: "gramsOfCarbs",
                    label: Localizables.CarbItemForm.labelCarbohydrates,
                    placeholder: Localizables.CarbItemForm.placeholderCarbohydrates,
                    type: .decimal,
                    required: true,
                    min: 0,
                    max: 10000
                ),
                FieldDescriptor(
                    id: "caffeine",
                    label: Localizables.CarbItemForm.labelCaffeine,
                    placeholder: Localizables.CarbItemForm.placeholderCaffeine,
                    type: .decimal,
                    min: 0,
                    max: 10000
                ),
                FieldDescriptor(
                    id: "sodium",
                    label: Localizables.CarbItemForm.labelSodium,
                    placeholder: Localizables.CarbItemForm.placeholderSodium,
                    type: .decimal,
                    min: 0,
                    max: 10000
                ),
                FieldDescriptor(
                    id: "waterVolumeML",
                    label: Localizables.CarbItemForm.labelWaterVolume,
                    placeholder: Localizables.CarbItemForm.placeholderWaterVolume,
                    type: .decimal,
                    min: 1,
                    max: 10000
                ),
            ]
        ),
    ]

    public init(
        sections: [FormSection] = CarbItemFormViewModel.defaultSections,
        existingItem: CarbItem? = nil,
        saveAction: @escaping (CarbItem) -> Void
    ) {
        self.sections = sections
        self.existingItem = existingItem
        self.saveAction = saveAction
    }

    var initialFormResult: FormResult? {
        guard let item = existingItem else { return nil }
        return [
            "id": .string(item.id),
            "name": .string(item.name),
            "brand": .string(item.brand ?? ""),
            "gramsOfCarbs": .string(String(item.gramsOfCarbs)),
            "caffeine": item.caffeine.map { .string(String($0)) } ?? .none,
            "sodium": item.sodium.map { .string(String($0)) } ?? .none,
            "waterVolumeML": item.waterVolumeML.map { .string(String($0)) } ?? .none,
            "type": .string(item.type.rawValue),
        ]
    }

    func handleSubmit(result: FormResult) {
        func toDouble(_ key: String) -> Double? {
            Double(result[key]?.stringValue ?? "")
        }

        let item = CarbItem(
            id: existingItem?.id ?? UUID().uuidString,
            name: result["name"]?.stringValue ?? "",
            gramsOfCarbs: toDouble("gramsOfCarbs") ?? 0,
            caffeine: toDouble("caffeine"),
            sodium: toDouble("sodium"),
            waterVolumeML: toDouble("waterVolumeML"),
            type: CarbType(rawValue: result["type"]?.stringValue ?? "") ?? .gel,
            brand: {
                let brand = result["brand"]?.stringValue ?? ""
                return brand.isEmpty ? nil : brand
            }(),
            isCustom: true
        )

        saveAction(item)
    }
}
