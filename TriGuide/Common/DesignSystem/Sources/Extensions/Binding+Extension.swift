//
// TriGuide 2026
//

import SwiftUI

public extension Binding {
    func unwrap<T: Sendable>() -> Binding<T>? where Value == T? {
        guard let wrapped = wrappedValue else { return nil }
        return Binding<T>(
            get: { wrappedValue ?? wrapped },
            set: { wrappedValue = $0 }
        )
    }
}
