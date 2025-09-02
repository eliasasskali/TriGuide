//
//  RobotoFont.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 24/8/25.
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
        Roboto.allCases.forEach {
            if let url = Bundle.main.url(forResource: $0.rawValue, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
