//
//  TriGuide 2025
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimeCalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "plusminus")
                }

            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            Text("Material list")
                .tabItem {
                    Label("Material list", systemImage: "checkmark.square")
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
