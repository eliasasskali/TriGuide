//
//  TriGuide 2025
//

import SwiftUI

public extension Font {
    enum Custom {
        @MainActor
        public struct Style {
            private static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let familyName: String

            public var font1: Font { .custom(familyName, size: 10 + Self.increment()) }
            public var font2: Font { .custom(familyName, size: 12 + Self.increment()) }
            public var font3: Font { .custom(familyName, size: 14 + Self.increment()) }
            public var font4: Font { .custom(familyName, size: 16 + Self.increment()) }
            public var font5: Font { .custom(familyName, size: 18 + Self.increment()) }

            private static func increment() -> CGFloat {
                isIpad ? 2 : 0
            }
        }

        public static let Bold = Style(familyName: Roboto.bold.rawValue)
        public static let Medium = Style(familyName: Roboto.medium.rawValue)
        public static let Regular = Style(familyName: Roboto.regular.rawValue)
        public static let Light = Style(familyName: Roboto.light.rawValue)
    }
}
