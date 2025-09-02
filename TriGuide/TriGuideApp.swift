//
//  TriGuideApp.swift
//  TriGuide
//
//  Created by Elias Asskali Assakali on 1/7/25.
//

import SwiftUI

@main
struct TriGuideApp: App {
    init() {
        RobotoFont.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.font, .Custom.Regular.font3)
        }
    }
}
