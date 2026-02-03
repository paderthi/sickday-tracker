import SwiftUI
import SwiftData

@main
struct SickDayTrackerApp: App {
    init() {
        if CommandLine.arguments.contains("UI-Testing") {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DailyLog.self, SicknessEpisode.self])
    }
}
