//
// TriGuide 2025
//

import Foundation
import NavigationKit

public class RaceCalculatorCoordinator: BaseCoordinator<Never, Never, RaceCalculatorView> {
    let factory: RaceCalculatorViewFactory

    public init(factory: RaceCalculatorViewFactory) {
        self.factory = factory
        super.init()
    }

    public override func start() -> RaceCalculatorView {
        factory.buildRaceCalculatorView()
    }
}
