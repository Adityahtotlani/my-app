import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home",      systemImage: "house.fill") }
            PracticeView()
                .tabItem { Label("Practice",  systemImage: "play.fill") }
            ProgressView_()
                .tabItem { Label("Progress",  systemImage: "chart.bar.fill") }
            CommunityView()
                .tabItem { Label("Community", systemImage: "person.3.fill") }
            ProfileView()
                .tabItem { Label("Profile",   systemImage: "person.fill") }
        }
        .accentColor(.skyIndigo)
    }
}
