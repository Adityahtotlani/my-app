import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore

    private var practicedToday: Bool {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return store.localPracticedDates.contains(f.string(from: Date()))
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            PracticeView()
                .tabItem { Label("Practice", systemImage: "play.circle") }
                .badge(practicedToday ? 0 : 1)

            ProgressView_()
                .tabItem { Label("Progress", systemImage: "chart.bar") }

            CommunityView()
                .tabItem { Label("Community", systemImage: "person.3") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .tint(.skyIndigo)
    }
}
