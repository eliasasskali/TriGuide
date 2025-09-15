//
//  TriGuide 2025
//

import Foundation

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
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        if let formatted = formatter.string(from: NSNumber(value: distanceInUnit)) {
            return String(formatted)
        }
        return String(format: "%.2f", distanceInUnit)
    }
}
