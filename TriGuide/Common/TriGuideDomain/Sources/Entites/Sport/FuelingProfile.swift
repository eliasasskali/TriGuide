//
// TriGuide 2025
//

import Foundation
import Localization

public enum FuelingProfile: String, CaseIterable {
    case amateur
    case trained
    case uncapped

    public var localized: String {
        switch self {
        case .amateur:
            return Localizables.FuelingProfile.amateur
        case .trained:
            return Localizables.FuelingProfile.trained
        case .uncapped:
            return Localizables.FuelingProfile.uncapped
        }
    }
}
