//
//  TriGuide 2025
//

import Foundation
import TriGuideDomain

struct RaceSplit: Equatable {
    let distance: Double
    let splitTime: TimeInterval
    let cumulativeTime: TimeInterval

    func formattedDistance(with unit: DistanceUnit) -> String {
        let factor = switch unit {
        case .kilometers:
            UnitTransformationConstants.metersInKm
        case .miles:
            UnitTransformationConstants.metersInMile
        case .meters:
            1.0
        case .yards:
            UnitTransformationConstants.metersInYard
        }

        let distanceInUnit = distance / factor
        return distanceInUnit.formattedAsDecimal()
    }
}
