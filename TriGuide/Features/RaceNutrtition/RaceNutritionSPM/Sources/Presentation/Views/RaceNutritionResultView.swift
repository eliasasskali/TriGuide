//
// TriGuide 2025
//

import SwiftUI
import CarbItemsSPM
import TriGuideDomain

struct RaceNutritionResultView: View {
    let fuelingResult: FuelingResult

    @State private var shouldShowSelectedItems = false

    var roundedTimeLine: [FuelingEvent] {
        fuelingResult.timeLine.map { event in
            let consumption = switch event.consumption {
            case .instant(let time):
                FuelingEvent.Consumption.instant(time: time.roundToMultiple(rule: .down))
            case .interval(let startTime, let endTime):
                FuelingEvent.Consumption.interval(
                    start: startTime.roundToMultiple(rule: .down),
                    end: endTime.roundToMultiple(rule: .up)
                )
            }

            return FuelingEvent(consumption: consumption, carbItem: event.carbItem)
        }
    }

    var itemTimeLine: [FuelingEvent] {
        roundedTimeLine.filter { event in
            switch event.carbItem.type {
            case .drink:
                return false
            default:
                return true
            }
        }
    }

    var drinkTimeLine: [FuelingEvent] {
        roundedTimeLine.filter { event in
            switch event.carbItem.type {
            case .drink:
                return true
            default:
                return false
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                planSummary

                selectedItems

                fuelingPlan
            }.padding()
        }
    }
}

// MARK: - Components

private extension RaceNutritionResultView {
    @ViewBuilder
    var fuelingPlan: some View {
        VStack(spacing: 16) {
            Text("Fueling plan:")
                .font(.Custom.Medium.font5)

            Grid {
                GridRow {
                    Text("Time")
                    Text("Item")
                }
                .font(.Custom.Medium.font3)

                Divider()

                ForEach(itemTimeLine, id: \.self) { event in
                    GridRow {
                        switch event.consumption {
                        case .instant(let time):
                            Text("\(time.formattedAsHourMinSec)")
                                .font(.Custom.Regular.font3)

                        case .interval(let startTime, let endTime):
                            Text("\(startTime.formattedAsHourMinSec) - \(endTime.formattedAsHourMinSec)")
                                .font(.Custom.Regular.font3)
                        }

                        Text("\(event.carbItem.name)")
                            .font(.Custom.Regular.font3)
                    }
                    .padding(.vertical, 4)

                    if event != itemTimeLine.last {
                        Divider()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Grid {
                GridRow {
                    Text("Interval")
                    Text("Drink")
                }
                .font(.Custom.Medium.font3)

                Divider()

                ForEach(drinkTimeLine, id: \.self) { event in
                    GridRow {
                        switch event.consumption {
                        case .instant(let time):
                            Text("\(time.formattedAsHourMinSec)")
                                .font(.Custom.Regular.font3)

                        case .interval(let startTime, let endTime):
                            Text("\(startTime.formattedAsHourMinSec) - \(endTime.formattedAsHourMinSec)")
                                .font(.Custom.Regular.font3)
                        }

                        Text("\(event.carbItem.name)")
                            .font(.Custom.Regular.font3)
                    }
                    .padding(.vertical, 4)

                    if event != drinkTimeLine.last {
                        Divider()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var planSummary: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Selected Carbs/Target:")
                        .font(.Custom.Medium.font3)
                    Spacer()
                    Text("\(Int(fuelingResult.totalSelectedCarbs))/\(Int(fuelingResult.totalCarbsTarget)) g")
                        .font(.Custom.Regular.font3)
                }

                HStack {
                    Text("Selected carbs per hour/Target:")
                        .font(.Custom.Medium.font3)
                    Spacer()
                    Text("\(Int(fuelingResult.actualCarbsPerHour))/\(Int(fuelingResult.carbTargetPerHour)) g")
                        .font(.Custom.Regular.font3)
                }
            }
        }
    }

    @ViewBuilder
    var selectedItems: some View {
        if shouldShowSelectedItems {
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    selectedItemsHeader

                    ForEach(fuelingResult.selectedItems) { selection in
                        Text("\(Int(selection.quantity))x \(selection.item.name) (\(Int(selection.item.gramsOfCarbs)) g)")
                            .font(.Custom.Regular.font3)
                            .lineLimit(1)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            GroupBox {
                selectedItemsHeader
            }
        }
    }

    var selectedItemsHeader: some View {
        HStack {
            Text("Selected Nutrition Items")
                .font(shouldShowSelectedItems ? .Custom.Medium.font4 : .Custom.Medium.font3)

            Spacer()

            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(shouldShowSelectedItems ? 180 : 0))
                .animation(.easeInOut, value: shouldShowSelectedItems)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            shouldShowSelectedItems.toggle()
        }
    }
}

#Preview {
    RaceNutritionResultView(
        fuelingResult: .init(
            timeLine: [
                FuelingEvent(consumption: .instant(time: TimeInterval(7200/5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(consumption: .instant(time: TimeInterval(7200*2/5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(consumption: .instant(time: TimeInterval(7200*3/5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel)),
                FuelingEvent(consumption: .instant(time: TimeInterval(7200*4/5)), carbItem: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel))
            ],
            totalCarbsTarget: 180,
            duration: 7200,
            selectedItems: [
                CarbItemSelection(item: .init(id: "id1", name: "gel 1", gramsOfCarbs: 45, type: .gel), quantity: 4),
                CarbItemSelection(item: .init(id: "id2", name: "Long text that should fit in a line", gramsOfCarbs: 45, type: .gel), quantity: 4)
            ],
            hourlyBreakdown: [
                IntervalFueling(duration: 3600, hourIndex: 0, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                IntervalFueling(duration: 3600, hourIndex: 1, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                IntervalFueling(duration: 3600, hourIndex: 2, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                IntervalFueling(duration: 3600, hourIndex: 3, carbGrams: 45, caffeine: 0, waterVolumeML: 0),
                IntervalFueling(duration: 3600, hourIndex: 4, carbGrams: 45, caffeine: 0, waterVolumeML: 0)
            ]
        )
    )
}

