//
// TriGuide 2026
//

import Foundation

/// A no-op implementation of `FuelingPlanEditAnalyticsService` that does nothing when its methods are called.
public struct FuelingPlanEditAnalyticsServiceNoOp: FuelingPlanEditAnalyticsService {
    public init() {}
    public func trackScreenView() {}
    public func trackPlanEdited(data _: FuelingPlanEditAnalyticsData) {}
}
