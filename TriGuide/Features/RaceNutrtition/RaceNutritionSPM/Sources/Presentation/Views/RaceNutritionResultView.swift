//
// TriGuide 2025
//

import SwiftUI
import CarbItemsSPM
import TriGuideDomain

struct RaceNutritionResultView: View {
    let fuelingResult: FuelingResult

    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Total Selected Carbs:")
                            .font(.Custom.Medium.font5)
                        Spacer()
                        Text("\(Int(fuelingResult.totalSelectedCarbs)) g")
                            .font(.Custom.Regular.font5)
                    }

                    HStack {
                        Text("Total Carbs Target:")
                            .font(.Custom.Medium.font5)
                        Spacer()
                        Text("\(Int(fuelingResult.totalCarbsTarget)) g")
                            .font(.Custom.Regular.font5)
                    }

                    HStack {
                        Text("Carb Target per Hour:")
                            .font(.Custom.Medium.font5)
                        Spacer()
                        Text("\(Int(fuelingResult.carbTargetPerHour)) g")
                            .font(.Custom.Regular.font5)
                    }

                    HStack {
                        Text("Actual carbs per Hour:")
                            .font(.Custom.Medium.font5)
                        Spacer()
                        Text("\(Int(fuelingResult.actualCarbsPerHour)) g")
                            .font(.Custom.Regular.font5)
                    }
                }
            }

            GroupBox {
                Text("Fueling plan:")
                    .font(.Custom.Medium.font5)

                ForEach(fuelingResult.timeLine, id: \.self) { event in
                    Text("\(event.time.formattedAsHourMinSec): \(event.carbItem.name)")
                        .font(.Custom.Regular.font5)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox {
                Text("Selected Nutrition Items:")
                    .font(.Custom.Medium.font5)

                ForEach(fuelingResult.selectedItems) { selection in
                    HStack {
                        Text("\(selection.item.name) x\(Int(selection.quantity))")
                            .font(.Custom.Regular.font5)
                        Spacer()
                            .padding(.top, 8)
                        let totalCarbs = selection.item.gramsOfCarbs * selection.quantity
                        Text("\(Int(totalCarbs)) g")
                            .font(.Custom.Regular.font5)
                    }
                }
            }
        }
    }
}

#Preview {
    RaceNutritionResultView(
        fuelingResult: .init(
            timeLine: [
                FuelingEvent(time: TimeInterval(7200/5), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(time: TimeInterval(7200*2/5), carbItem: .init(id: "id2", name: "gel 2", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(time: TimeInterval(7200*3/5), carbItem: .init(id: "id3", name: "gel 3", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(time: TimeInterval(7200*4/5), carbItem: .init(id: "id4", name: "gel 4", gramsOfCarbs: 45, type: .gel))
            ],
            totalCarbsTarget: 180,
            duration: 7200,
            selectedItems: [
                CarbItemSelection(
                    item: .init(id: "id1", name: "Test gel", gramsOfCarbs: 45, type: .gel),
                    quantity: 4
                )
            ]
        )
    )
}
