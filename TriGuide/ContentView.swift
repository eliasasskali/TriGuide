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
            if let carbItemsView = CarbItemsViewFactoryDefault.makeViewOrNil() {
                carbItemsView
                    .tabItem {
                        Label(Localizables.Tabs.home, systemImage: "fork.knife")
                    }
            }
//            Text(Localizables.Tabs.home)
//                .tabItem {
//                    Label(Localizables.Tabs.home, systemImage: "home")
//                }

            TimeCalculatorView()
                .tabItem {
                    Label(Localizables.Tabs.calculator, systemImage: "plusminus")
                }

//            Text(Localizables.Tabs.materialList)
//                .tabItem {
//                    Label(Localizables.Tabs.materialList, systemImage: "checkmark.square")
//                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
