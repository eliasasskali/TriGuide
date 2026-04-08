//
//  TriGuide 2025
//

import DesignSystem
import Firebase
import SwiftUI

@main
struct TriGuideApp: App {
    init() {
        RobotoFont.registerFonts()
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.font, .Custom.Regular.font3)
        }
    }
}
