//
//  TriGuide 2025
//

import AthleteProfile
import Localization
import RaceCalculatorSPM
import RaceNutritionSPM
import SwiftUI

struct ContentView: View {
    @StateObject private var raceCalculatorCoordinator: RaceCalculatorCoordinator
    @StateObject private var raceNutritionCoordinator: RaceNutritionCoordinator
    @StateObject private var athleteProfileCoordinator: AthleteProfileCoordinator

    init() {
        let factory = AppFactory()
        _raceNutritionCoordinator = StateObject(wrappedValue: factory.buildRaceNutritionCoordinator())
        _raceCalculatorCoordinator = StateObject(wrappedValue: factory.buildRaceCalculatorCoordinator())
        _athleteProfileCoordinator = StateObject(wrappedValue: factory.buildAthleteProfileCoordinator())
    }

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            raceNutritionCoordinator.start()
                .tag(0)
                .tabItem {
                    Label(Localizables.Tabs.sportNutrition, systemImage: "fork.knife")
                }

            raceCalculatorCoordinator.start()
                .tag(1)
                .tabItem {
                    Label(Localizables.Tabs.calculator, systemImage: "plusminus")
                }

            athleteProfileCoordinator.start()
                .tag(2)
                .tabItem {
                    Label(Localizables.Tabs.myAthleteProfile, systemImage: "person.crop.circle.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
