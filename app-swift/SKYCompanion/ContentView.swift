import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        // AUTH BYPASSED FOR TESTING — restore original logic when done:
        // if store.isAuthenticated { if store.hasOnboarded { MainTabView() } else { OnboardingView() } } else { AuthNavigationView() }
        MainTabView()
    }
}
