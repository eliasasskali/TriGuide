//
//  TriGuide 2025
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimeCalculatorView()
                .tabItem {
                    Label(Localizables.Tabs.calculator, systemImage: "plusminus")
                }

            Text(Localizables.Tabs.home)
                .tabItem {
                    Label(Localizables.Tabs.home, systemImage: "house")
                }

            Text(Localizables.Tabs.materialList)
                .tabItem {
                    Label(Localizables.Tabs.materialList, systemImage: "checkmark.square")
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
