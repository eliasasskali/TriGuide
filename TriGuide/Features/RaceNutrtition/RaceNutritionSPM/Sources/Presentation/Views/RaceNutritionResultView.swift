//
// TriGuide 2025
//

import SwiftUI
import CarbItemsSPM
import TriGuideDomain
import Localization

public struct RaceNutritionResultView: View {
    @ObservedObject private var coordinator: RaceNutritionCoordinator

    @State private var shouldShowSelectedItems = false

    @Binding var fuelingResult: FuelingResult

    public init(
        coordinator: RaceNutritionCoordinator,
        shouldShowSelectedItems: Bool = false,
        fuelingResult: Binding<FuelingResult>
    ) {
        self.coordinator = coordinator
        self.shouldShowSelectedItems = shouldShowSelectedItems
        _fuelingResult = fuelingResult
    }

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

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                planSummary
                selectedItems
                fuelingPlan
                hourlyBreakdown
            }.padding()
        }
    }
}

// MARK: - Components

private extension RaceNutritionResultView {
    @ViewBuilder
    var fuelingPlan: some View {
        GroupBox {
            VStack(spacing: 16) {
                HStack {
                    Text(Localizables.RaceNutritionResults.fuelingPlanTitle)
                        .font(.Custom.Medium.font5)

                    Spacer()

                    HStack(alignment: .center) {
                        Text(Localizables.RaceNutritionResults.fuelingPlanEditButtonLabel)
                            .font(.Custom.Regular.font3)
                        Image(systemName: "pencil")
                            .fixedSize()
                            .bold()
                    }
                    .onTapGesture {
                        coordinator.pushFuelingPlanFullView()
                    }
                }

                Grid {
                    GridRow {
                        Text(Localizables.RaceNutritionResults.fuelingPlanTimeColumnTitle)
                        Text(Localizables.RaceNutritionResults.fuelingPlanItemColumnTitle)
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
                        Text(Localizables.RaceNutritionResults.fuelingPlanIntervalColumnTitle)
                        Text(Localizables.RaceNutritionResults.fuelingPlanDrinkColumnTitle)
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
    }

    @ViewBuilder
    var planSummary: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(Localizables.RaceNutritionResults.fuelingPlanSelectedCarbsTargetLabel)
                        .font(.Custom.Medium.font3)
                    Spacer()
                    Text("\(Int(fuelingResult.totalSelectedCarbs))/\(Int(fuelingResult.totalCarbsTarget)) g")
                        .font(.Custom.Regular.font3)
                }

                HStack {
                    Text(Localizables.RaceNutritionResults.fuelingPlanSelectedCarbsHourTargetLabel)
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
            Text(Localizables.RaceNutritionResults.fuelingPlanSelectedNutritionItemsTitle)
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

    var hourlyBreakdown: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                Text(Localizables.RaceNutritionResults.fuelingPlanHourlyBreakdownTitle)
                    .font(.Custom.Medium.font5)

                IntervalBreakdownView(breakdown: fuelingResult.hourlyBreakdown)
            }
        }
    }
}

#Preview {
    RaceNutritionResultView(
        coordinator: RaceNutritionCoordinator(
            factory: RaceNutritionViewFactoryDefault(dependencies: .init())
        ),
        fuelingResult: .constant(
            .init(
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
    )
}

