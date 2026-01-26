//
// TriGuide2025
//

import Foundation
import SwiftUI

@MainActor
public protocol Coordinator: ObservableObject {
    associatedtype ContentView: View

    /// Must return the main entry view for this coordinator.
    @ViewBuilder
    func start() -> ContentView
}
