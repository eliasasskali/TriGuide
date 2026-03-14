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
    private let coordinator: RaceNutritionCoordinator?

    // MARK: - Initializer

    init(
        viewModel: StoredNutritionPlansListViewModel,
        coordinator: RaceNutritionCoordinator? = nil
    ) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.coordinator = coordinator
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
                        Button {
                            coordinator?.openStoredFuelingResult(plan)
                        } label: {
                            cell(plan)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { offsets in
                        Task {
                            await viewModel.deletePlan(at: offsets)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
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

            HStack(spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text(plan.duration.formattedAsHourMinSec)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text(
                        Localizables.RaceNutritionResults.storedPlansItemGramsHourValue(
                            Int(plan.actualCarbsPerHour.rounded())
                        )
                    )
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.secondary)
                    Text("\(plan.selectedItems.count)")
                }
                .frame(maxWidth: .infinity)
            }
            .font(.Custom.Regular.font2)
        }
        .cardBackground(innerHorizontalPadding: 12, innerVerticalPadding: 12)
    }
}

#Preview {
    RaceNutritionViewFactoryDefault(dependencies: .init()).buildStoredNutritionPlansListView(coordinator: nil)
}
