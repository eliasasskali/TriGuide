//
// TriGuide 2025
//

import Foundation

// MARK: - RaceDistance protocol

public protocol RaceDistance: Hashable, CaseIterable {
    var meters: Double { get }
    var displayName: String { get }
}
