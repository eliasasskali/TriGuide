//
//  TriGuide 2025
//

import Foundation

public extension Double {
    func formattedAsDecimal(
        minFractionDigits: Int = 0,
        maxFractionDigits: Int = 3
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
