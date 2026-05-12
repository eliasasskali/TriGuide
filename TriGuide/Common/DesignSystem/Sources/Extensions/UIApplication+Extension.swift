//
// TriGuide 2026
//

#if canImport(UIKit)
    import UIKit

    extension UIApplication {
        static func resignFirstResponder() {
            shared
                .sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
        }
    }
#endif
