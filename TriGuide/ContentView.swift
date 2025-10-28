//
//  TriGuide 2025
//

import SwiftUI
import Localization
import RaceCalculatorSPM
import CarbItemsSPM

struct ContentView: View {
    var body: some View {
        TabView {
            TimeCalculatorView()
                .tabItem {
                    Label(Localizables.Tabs.calculator, systemImage: "plusminus")
                }

            CarbItemsViewFactoryDefault.makeView()
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
