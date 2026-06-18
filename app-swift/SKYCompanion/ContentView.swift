import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        // AUTH BYPASSED FOR TESTING — skip login, route by onboarding state
        if store.hasOnboarded {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}
