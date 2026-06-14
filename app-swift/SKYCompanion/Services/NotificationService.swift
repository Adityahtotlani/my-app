import UserNotifications

struct NotificationService {
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleReminder(hour: Int, minute: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["sky_daily_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Time for SKY Practice"
        content.body = "Start your day with clarity and focus. Your guided session is ready."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "sky_daily_reminder", content: content, trigger: trigger)
        try? await center.add(request)
    }

    // Fires at 8 PM every evening to remind practitioners with an active streak.
    // Cancel it for the day by calling cancelStreakRiskReminder() after a session is logged.
    static func scheduleStreakRiskReminder(streak: Int) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["sky_streak_risk"])

        let content = UNMutableNotificationContent()
        content.title = "Your \(streak)-day streak is at risk"
        content.body = "You haven't practiced yet today. 15 minutes is all it takes — keep the momentum going."
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "sky_streak_risk", content: content, trigger: trigger)
        try? await center.add(request)
    }

    static func cancelStreakRiskReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["sky_streak_risk"])
    }
}
