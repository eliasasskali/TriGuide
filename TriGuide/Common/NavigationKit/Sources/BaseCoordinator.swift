//
// TriGuide 2025
//

import SwiftUI

// MATK: - BaseCoordinator

@MainActor
open class BaseCoordinator<Route: Hashable, Sheet: Identifiable & Equatable, ContentView: View>: Coordinator {
    @Published private var path: NavigationPath = .init()
    @Published private var sheet: Sheet? = nil

    // MARK: - Bindings for SwiftUI so we don't expose @Published properties directly and the methods are used instead

    public var pathBinding: Binding<NavigationPath> {
        Binding(
            get: { self.path },
            set: { self.path = $0 }
        )
    }

    public var sheetBinding: Binding<Sheet?> {
        Binding(
            get: { self.sheet },
            set: { self.sheet = $0 }
        )
    }

    public init() {}

    // MARK: - Abstract start(): Subclasses must override

    open func start() -> ContentView {
        fatalError("Subclasses of BaseCoordinator must override start()")
        // Won't reach this line, to satisfy the compiler
        return EmptyView() as! ContentView
    }

    // MARK: - Push and pop navigation

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    // MARK: - Present and dismiss sheets

    public func presentSheet(sheet: Sheet) {
        self.sheet = sheet
    }

    public func dismissSheet() {
        sheet = nil
    }
}
