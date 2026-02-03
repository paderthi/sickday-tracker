import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)

            EpisodesView()
                .tabItem {
                    Label("Episodes", systemImage: "heart.text.square")
                }
                .tag(1)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView(isPresented: $showingOnboarding)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyLog.self, SicknessEpisode.self])
}
