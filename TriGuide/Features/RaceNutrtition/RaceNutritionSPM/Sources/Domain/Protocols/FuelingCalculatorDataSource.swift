//
// TriGuide
//

import Foundation
import TriGuideDomain

public protocol FuelingCalculatorDataSource: Sendable {
    func calculateFueling(from fuelingInput: FuelingInput) -> FuelingResult
}
