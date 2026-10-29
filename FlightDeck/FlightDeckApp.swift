import SwiftUI
import UIKit

@main
struct FlightDeckApp: App {
    @StateObject private var store = FlightPlanStore()
    @StateObject private var theme = FlightDeckTheme()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(theme)
                .tint(theme.accentColor)
                .fontDesign(theme.fontStyle.design)
                .preferredColorScheme(.dark)
        }
    }
}

