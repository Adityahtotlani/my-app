import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        Group {
            if store.isAuthenticated {
                if store.hasOnboarded {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            } else {
                AuthNavigationView()
            }
        }
        .animation(.easeInOut, value: store.isAuthenticated)
        .animation(.easeInOut, value: store.hasOnboarded)
    }
}
