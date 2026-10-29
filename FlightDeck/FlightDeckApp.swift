import SwiftUI
import UIKit

@main
struct FlightDeckApp: App {
    @StateObject private var store = FlightPlanStore()
    var body: some Scene {
        WindowGroup { ContentView().environmentObject(store).preferredColorScheme(.dark) }
    }
}
