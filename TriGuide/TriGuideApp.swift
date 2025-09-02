//
//  TriGuide 2025
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
