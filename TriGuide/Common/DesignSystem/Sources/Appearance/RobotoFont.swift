//
//  TriGuide 2025
//

import SwiftUI

// MARK: - Roboto

public enum Roboto: String, CaseIterable {
    case bold = "Roboto-Bold"
    case extraLight = "Roboto-ExtraLight"
    case light = "Roboto-Light"
    case medium = "Roboto-Medium"
    case regular = "Roboto-Regular"
    case semiBold = "Roboto-SemiBold"
}

// MARK: - RobotoFont

public enum RobotoFont {
    public static func registerFonts() {
        for item in Roboto.allCases {
            if let url = Bundle.module.url(forResource: item.rawValue, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
