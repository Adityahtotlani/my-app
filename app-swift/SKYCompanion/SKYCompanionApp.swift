import SwiftUI

@main
struct SKYCompanionApp: App {
    @StateObject private var store = AppStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            // Re-arm streak-risk notification each time app comes to foreground
            if store.localStreakAtRisk {
                Task {
                    await NotificationService.scheduleStreakRiskReminder(
                        streak: store.localCurrentStreak
                    )
                }
            }
        }
    }
}
