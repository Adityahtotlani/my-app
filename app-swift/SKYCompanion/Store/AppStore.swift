import Foundation
import SwiftUI

struct ReminderOption: Identifiable {
    let id = UUID()
    let label: String
    let hour: Int
    let minute: Int

    var displayTime: String {
        let period = hour < 12 ? "AM" : "PM"
        let h = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%d:%02d %@", h, minute, period)
    }
}

let reminderOptions: [ReminderOption] = [
    ReminderOption(label: "Morning · 6:30 AM", hour: 6,  minute: 30),
    ReminderOption(label: "Midday · 12:00 PM", hour: 12, minute: 0),
    ReminderOption(label: "Evening · 7:00 PM", hour: 19, minute: 0),
]

let levelThresholds = [0, 500, 1500, 3500, 7000, 12000]

@MainActor
class AppStore: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated: Bool
    @Published var hasOnboarded: Bool
    @Published var intention: String?
    @Published var reminderHour: Int
    @Published var reminderMinute: Int

    @AppStorage("auth_token")    private var storedToken: String = ""
    @AppStorage("has_onboarded") private var storedOnboarded: Bool = false
    @AppStorage("reminder_hour") private var storedReminderHour: Int = 6
    @AppStorage("reminder_min")  private var storedReminderMin: Int = 30

    var token: String { storedToken }

    init() {
        isAuthenticated = UserDefaults.standard.string(forKey: "auth_token").map { !$0.isEmpty } ?? false
        hasOnboarded    = UserDefaults.standard.bool(forKey: "has_onboarded")
        reminderHour    = UserDefaults.standard.integer(forKey: "reminder_hour").nonZeroOr(6)
        reminderMinute  = UserDefaults.standard.integer(forKey: "reminder_min")
    }

    // MARK: - Auth

    func login(email: String, password: String) async throws {
        struct Body: Encodable { let email, password: String }
        let res: AuthResponse = try await APIService.request(
            path: "/api/auth/login", method: "POST",
            body: Body(email: email, password: password)
        )
        storedToken = res.token
        user = res.user
        isAuthenticated = true
    }

    func register(email: String, password: String, courseCode: String) async throws {
        struct Body: Encodable { let email, password, courseCode: String }
        let res: AuthResponse = try await APIService.request(
            path: "/api/auth/register", method: "POST",
            body: Body(email: email, password: password, courseCode: courseCode)
        )
        storedToken = res.token
        user = res.user
        isAuthenticated = true
    }

    func logout() {
        storedToken = ""
        storedOnboarded = false
        user = nil
        isAuthenticated = false
        hasOnboarded = false
        intention = nil
    }

    // MARK: - User

    func refreshUser() async {
        guard !storedToken.isEmpty else { return }
        do {
            user = try await APIService.request(path: "/api/auth/me", token: storedToken)
        } catch {
            print("refreshUser failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Sessions

    func logSession(type: String, durationSeconds: Int, moodScore: Int?) async {
        guard !storedToken.isEmpty else { return }
        struct Body: Encodable {
            let type: String
            let durationSeconds: Int
            let moodScore: Int?
        }
        do {
            let _: LogSessionResponse = try await APIService.request(
                path: "/api/sessions/log", method: "POST",
                body: Body(type: type, durationSeconds: durationSeconds, moodScore: moodScore),
                token: storedToken
            )
            await refreshUser()
        } catch {
            print("logSession failed: \(error.localizedDescription)")
        }
    }

    func fetchHistory() async throws -> [Session] {
        try await APIService.request(path: "/api/sessions/history", token: storedToken)
    }

    func fetchStreakCalendar() async throws -> [String] {
        let res: StreakCalendarResponse = try await APIService.request(
            path: "/api/sessions/streak-calendar", token: storedToken
        )
        return res.dates
    }

    func fetchMoodTrend() async throws -> [MoodPoint] {
        struct Raw: Codable { let day: Int; let mood: Double }
        let raw: [Raw] = try await APIService.request(
            path: "/api/sessions/mood-trend", token: storedToken
        )
        return raw.enumerated().map { MoodPoint(id: $0.offset, day: $0.element.day, mood: $0.element.mood) }
    }

    // MARK: - Onboarding & Reminder

    func completeOnboarding(intention: String, hour: Int, minute: Int) {
        self.intention = intention
        storedReminderHour = hour
        storedReminderMin  = minute
        reminderHour       = hour
        reminderMinute     = minute
        storedOnboarded    = true
        hasOnboarded       = true
    }

    func setReminder(hour: Int, minute: Int) {
        storedReminderHour = hour
        storedReminderMin  = minute
        reminderHour       = hour
        reminderMinute     = minute
    }
}

private extension Int {
    func nonZeroOr(_ fallback: Int) -> Int { self == 0 ? fallback : self }
}
