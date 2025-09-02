//
//  TriGuide 2025
//

import SwiftUI

public extension Font {
    enum Custom {
        struct Style {
            let familyName: String

            var font1: Font { .custom(familyName, size: 10 + increment()) }
            var font2: Font { .custom(familyName, size: 12 + increment()) }
            var font3: Font { .custom(familyName, size: 14 + increment()) }
            var font4: Font { .custom(familyName, size: 16 + increment()) }
            var font5: Font { .custom(familyName, size: 18 + increment()) }

            private func increment() -> CGFloat {
                UIDevice.current.userInterfaceIdiom == .pad ? 2 : 0
            }
        }

        static let Regular = Style(familyName: Roboto.regular.rawValue)
        static let Medium = Style(familyName: Roboto.medium.rawValue)
        static let Bold = Style(familyName: Roboto.bold.rawValue)
    }
}
