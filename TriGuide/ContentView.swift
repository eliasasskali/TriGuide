//
//  TriGuide 2025
//

import Localization
import RaceCalculatorSPM
import RaceNutritionSPM
import SwiftUI

struct ContentView: View {
    @StateObject private var raceCalculatorCoordinator: RaceCalculatorCoordinator
    @StateObject private var raceNutritionCoordinator: RaceNutritionCoordinator

    init() {
        let raceNutritionFactory = RaceNutritionViewFactoryDefault(dependencies: .init())
        _raceNutritionCoordinator = StateObject(
            wrappedValue: RaceNutritionCoordinator(factory: raceNutritionFactory)
        )
        let raceCalculatorFactory = RaceCalculatorViewFactoryDefault(dependencies: .init())
        _raceCalculatorCoordinator = StateObject(
            wrappedValue: RaceCalculatorCoordinator(factory: raceCalculatorFactory)
        )
    }

    var body: some View {
        TabView {
            raceNutritionCoordinator.start()
                .tabItem {
                    Label(Localizables.Tabs.home, systemImage: "fork.knife")
                }
//            Text(Localizables.Tabs.home)
//                .tabItem {
//                    Label(Localizables.Tabs.home, systemImage: "home")
//                }

            raceCalculatorCoordinator.start()
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
