//
// TriGuide 2026
//

import DesignSystem
import Localization
import SwiftUI
import TriGuideDomain

public struct StoredNutritionPlansListView: View {
    // MARK: - Dependencies

    @ObservedObject private var viewModel: StoredNutritionPlansListViewModel

    // MARK: - Initializer

    init(viewModel: StoredNutritionPlansListViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.plans.isEmpty {
                ContentUnavailableView {
                    Label(Localizables.RaceNutritionResults.storedPlansNoStoredPlans, systemImage: "tray")
                }
            } else {
                List {
                    ForEach(viewModel.plans, id: \.self) { plan in
                        cell(plan)
                            .contentShape(Rectangle())
                            .onTapGesture {}
                    }
                    .onDelete { offsets in
                        Task {
                            await viewModel.deletePlan(at: offsets)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(Localizables.RaceNutritionResults.storedPlansTitle)
        .task {
            await viewModel.fetchStoredPlans()
        }
    }
}

private extension StoredNutritionPlansListView {
    @ViewBuilder
    func cell(_ plan: FuelingResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.name ?? Localizables.RaceNutritionResults.storedPlansItemUnnamedPlan)
                .font(.Custom.Medium.font4)
                .lineLimit(1)

            HStack {
                Text(Localizables.RaceNutritionResults.storedPlansItemDurationLabel)
                    .font(.Custom.Medium.font3)
                Spacer()
                Text(plan.duration.formattedAsHourMinSec)
                    .font(.Custom.Regular.font3)
            }

            HStack {
                Text(Localizables.RaceNutritionResults.storedPlansItemGramsHourLabel)
                    .font(.Custom.Medium.font3)
                Spacer()
                Text(
                    Localizables.RaceNutritionResults.storedPlansItemGramsHourValue(
                        Int(plan.actualCarbsPerHour.rounded())
                    )
                )
                .font(.Custom.Regular.font3)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    RaceNutritionViewFactoryDefault(dependencies: .init()).buildStoredNutritionPlansListView()
}
