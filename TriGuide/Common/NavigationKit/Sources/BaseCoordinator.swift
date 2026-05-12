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

    // MARK: - External navigation handler

    /// When set, `push(_:)` delegates to this closure instead of appending to the internal path.
    /// This allows a parent coordinator to own the NavigationStack while child coordinators
    /// still call `push()` as usual.
    public var externalPushHandler: ((Route) -> Void)?

    // MARK: - Abstract start(): Subclasses must override

    open func start() -> ContentView {
        fatalError("Subclasses of BaseCoordinator must override start()")
        // Unreachable — satisfies compiler return type requirement
        return EmptyView() as! ContentView // swiftlint:disable:this force_cast
    }

    // MARK: - Push and pop navigation

    public func push(_ route: Route) {
        if let externalPushHandler {
            externalPushHandler(route)
        } else {
            path.append(route)
        }
    }

    /// Push any Hashable value onto the internal path (useful for type-erased multi-coordinator stacks).
    public func pushAny<T: Hashable>(_ value: T) {
        path.append(value)
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
