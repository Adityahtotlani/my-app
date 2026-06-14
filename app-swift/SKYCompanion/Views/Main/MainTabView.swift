import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @SceneStorage("selectedTab") private var selectedTab = 0

    private var practicedToday: Bool {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return store.localPracticedDates.contains(f.string(from: Date()))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            PracticeView()
                .tabItem { Label("Practice", systemImage: "play.circle.fill") }
                .badge(practicedToday ? 0 : 1)
                .tag(1)

            ProgressView_()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(2)

            CommunityView()
                .tabItem { Label("Community", systemImage: "person.3.fill") }
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(4)
        }
        .tint(.skyIndigo)
    }
}
