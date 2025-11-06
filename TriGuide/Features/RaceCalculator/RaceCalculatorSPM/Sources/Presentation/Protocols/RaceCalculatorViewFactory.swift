//
// TriGuide 2025
//

import Foundation

public protocol RaceCalculatorViewFactory {
    @MainActor func buildRaceCalculatorView() -> RaceCalculatorView
}
