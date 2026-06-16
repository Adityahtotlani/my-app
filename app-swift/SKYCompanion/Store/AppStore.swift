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

struct Achievement: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let earned: Bool
}

struct WeeklyCount: Identifiable {
    let id: Int
    let label: String
    let count: Int
}

@MainActor
class AppStore: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated: Bool
    @Published var hasOnboarded: Bool
    @Published var intention: String?
    @Published var reminderHour: Int
    @Published var reminderMinute: Int
    @Published private(set) var localSessions: [LocalSession] = []
    @Published private(set) var localSatsangCheckIns: [String] = []

    @AppStorage("auth_token")      private var storedToken: String = ""
    @AppStorage("has_onboarded")   private var storedOnboarded: Bool = false
    @AppStorage("reminder_hour")   private var storedReminderHour: Int = 6
    @AppStorage("reminder_min")    private var storedReminderMin: Int = 30
    @AppStorage("local_name")      var localName: String = ""
    @AppStorage("user_intention")  private var storedIntention: String = ""
    @AppStorage("weekly_goal")     var weeklyGoal: Int = 5
    @AppStorage("healthkit_enabled") var healthKitEnabled: Bool = false

    var token: String { storedToken }

    private let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        isAuthenticated = UserDefaults.standard.string(forKey: "auth_token").map { !$0.isEmpty } ?? false
        hasOnboarded    = UserDefaults.standard.bool(forKey: "has_onboarded")
        reminderHour    = UserDefaults.standard.integer(forKey: "reminder_hour").nonZeroOr(6)
        reminderMinute  = UserDefaults.standard.integer(forKey: "reminder_min")

        if let data = UserDefaults.standard.data(forKey: "local_sessions"),
           let decoded = try? JSONDecoder().decode([LocalSession].self, from: data) {
            localSessions = decoded
        }

        intention = storedIntention.isEmpty ? nil : storedIntention

        if let data = UserDefaults.standard.data(forKey: "satsang_checkins"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            localSatsangCheckIns = decoded
        }
    }

    // MARK: - Local Session Tracking

    func saveLocalSession(type: String, durationSeconds: Int, moodScore: Int?, note: String? = nil) {
        let record = LocalSession(
            date: isoFormatter.string(from: Date()),
            type: type,
            durationSeconds: durationSeconds,
            moodScore: moodScore,
            note: note
        )
        localSessions.append(record)
        if let data = try? JSONEncoder().encode(localSessions) {
            UserDefaults.standard.set(data, forKey: "local_sessions")
        }
        // Write mindful session to Apple Health if enabled
        if healthKitEnabled {
            Task { await HealthKitService.shared.writeMindfulSession(durationSeconds: durationSeconds) }
        }
        // Practiced today — streak is safe, cancel the at-risk nudge
        NotificationService.cancelStreakRiskReminder()
        // Re-arm for tomorrow if they have a streak worth protecting
        let streak = localCurrentStreak
        if streak >= 2 {
            Task {
                await NotificationService.scheduleStreakRiskReminder(streak: streak)
            }
        }
    }

    var localPracticedDates: Set<String> {
        Set(localSessions.map { $0.date })
    }

    var localStreakAtRisk: Bool {
        let dates = localPracticedDates
        let today = isoFormatter.string(from: Date())
        let yesterday = isoFormatter.string(
            from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        )
        return !dates.contains(today) && dates.contains(yesterday) && localCurrentStreak >= 2
    }

    var localCurrentStreak: Int {
        let cal = Calendar.current
        let dates = localPracticedDates
        var date = Date()
        // If not practiced today, count back from yesterday
        if !dates.contains(isoFormatter.string(from: date)) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: date) else { return 0 }
            date = yesterday
        }
        var streak = 0
        while dates.contains(isoFormatter.string(from: date)) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    var localMaxStreak: Int {
        let sorted = localPracticedDates.sorted()
        guard !sorted.isEmpty else { return 0 }
        let cal = Calendar.current
        var maxS = 1, current = 1
        for i in 1..<sorted.count {
            guard let d1 = isoFormatter.date(from: sorted[i-1]),
                  let d2 = isoFormatter.date(from: sorted[i]) else { continue }
            if cal.dateComponents([.day], from: d1, to: d2).day == 1 {
                current += 1; maxS = max(maxS, current)
            } else { current = 1 }
        }
        return maxS
    }

    var localTotalMinutes: Int {
        localSessions.reduce(0) { $0 + ($1.durationSeconds / 60) }
    }

    var localTotalXP: Int {
        let practiceXP = localSessions.reduce(0) { $0 + ($1.type == "full" ? 100 : 50) }
        return practiceXP + localSatsangCheckIns.count * 75
    }

    func logSatsangCheckIn() {
        let today = isoFormatter.string(from: Date())
        guard !localSatsangCheckIns.contains(today) else { return }
        localSatsangCheckIns.append(today)
        if let data = try? JSONEncoder().encode(localSatsangCheckIns) {
            UserDefaults.standard.set(data, forKey: "satsang_checkins")
        }
    }

    var checkedInSatsangToday: Bool {
        localSatsangCheckIns.contains(isoFormatter.string(from: Date()))
    }

    var localLevel: Int {
        let xp = localTotalXP
        return max(1, min(levelThresholds.filter { xp >= $0 }.count, 6))
    }

    var achievements: [Achievement] {
        let streak  = max(localCurrentStreak, localMaxStreak)
        let total   = localSessions.count
        let full    = localSessions.filter { $0.type == "full" }.count
        let xp      = localTotalXP
        let satsangs = localSatsangCheckIns.count
        return [
            Achievement(id: "first_breath",  icon: "wind",               title: "First Breath",
                        description: "Complete your first SKY session",   earned: total >= 1),
            Achievement(id: "weekly",         icon: "flame.fill",          title: "Weekly Warrior",
                        description: "Reach a 7-day streak",              earned: streak >= 7),
            Achievement(id: "habit",          icon: "checkmark.seal.fill", title: "Habit Builder",
                        description: "Reach a 21-day streak",             earned: streak >= 21),
            Achievement(id: "forty_days",     icon: "sparkles",            title: "40-Day Transformer",
                        description: "Reach a 40-day streak",             earned: streak >= 40),
            Achievement(id: "satsang",        icon: "person.3.fill",       title: "Satsang Soul",
                        description: "Attend your first satsang",         earned: satsangs >= 1),
            Achievement(id: "ten_sessions",   icon: "trophy.fill",         title: "Dedicated",
                        description: "Complete 10 sessions",              earned: total >= 10),
            Achievement(id: "full_five",      icon: "play.circle.fill",    title: "Full Circle",
                        description: "Complete 5 full-length sessions",   earned: full >= 5),
            Achievement(id: "xp_500",         icon: "star.fill",           title: "XP Milestone",
                        description: "Earn 500 total XP",                 earned: xp >= 500),
        ]
    }

    var todaySession: LocalSession? {
        localSessions.last(where: { $0.date == isoFormatter.string(from: Date()) })
    }

    var localMoodTrend: [MoodPoint] {
        let withMood = localSessions.compactMap { s -> (String, Int)? in
            guard let m = s.moodScore else { return nil }
            return (s.date, m)
        }
        return withMood.suffix(14).enumerated().map {
            MoodPoint(id: $0.offset, day: $0.offset + 1, mood: Double($0.element.1))
        }
    }

    var localSessionsAsSessions: [Session] {
        localSessions.enumerated().map { i, s in
            Session(id: i, type: s.type, durationSeconds: s.durationSeconds,
                    moodScore: s.moodScore, completedAt: s.date, note: s.note)
        }
    }

    var sessionsPerWeekHistory: [WeeklyCount] {
        let cal = Calendar.current
        let today = Date()
        let dateFmt = DateFormatter(); dateFmt.dateFormat = "M/d"
        var result = [WeeklyCount]()
        for weeksBack in (0..<8).reversed() {
            let refDate = cal.date(byAdding: .weekOfYear, value: -weeksBack, to: today) ?? today
            let weekday = cal.component(.weekday, from: refDate)
            let daysFromMonday = weekday == 1 ? 6 : weekday - 2
            let monday = cal.startOfDay(for: cal.date(byAdding: .day, value: -daysFromMonday, to: refDate) ?? refDate)
            guard let weekEnd = cal.date(byAdding: .day, value: 7, to: monday) else { continue }
            let label: String
            if weeksBack == 0 { label = "This" }
            else if weeksBack == 1 { label = "Last" }
            else { label = dateFmt.string(from: monday) }
            let count = localSessions.filter {
                guard let d = isoFormatter.date(from: $0.date) else { return false }
                let day = cal.startOfDay(for: d)
                return day >= monday && day < weekEnd
            }.count
            result.append(WeeklyCount(id: 7 - weeksBack, label: label, count: count))
        }
        return result
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
        storedToken     = ""
        storedOnboarded = false
        storedIntention = ""
        user            = nil
        isAuthenticated = false
        hasOnboarded    = false
        intention       = nil
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

    func logSession(type: String, durationSeconds: Int, moodScore: Int?, note: String? = nil) async {
        saveLocalSession(type: type, durationSeconds: durationSeconds, moodScore: moodScore, note: note)

        guard !storedToken.isEmpty else { return }
        struct Body: Encodable {
            let type: String
            let durationSeconds: Int
            let moodScore: Int?
            let note: String?
        }
        do {
            let _: LogSessionResponse = try await APIService.request(
                path: "/api/sessions/log", method: "POST",
                body: Body(type: type, durationSeconds: durationSeconds, moodScore: moodScore, note: note),
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
        self.intention   = intention
        storedIntention  = intention
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

    func setIntention(_ value: String) {
        intention       = value
        storedIntention = value
    }

    func resetAllLocalData() {
        localSessions          = []
        localSatsangCheckIns   = []
        UserDefaults.standard.removeObject(forKey: "local_sessions")
        UserDefaults.standard.removeObject(forKey: "satsang_checkins")
        NotificationService.cancelStreakRiskReminder()
    }
}

private extension Int {
    func nonZeroOr(_ fallback: Int) -> Int { self == 0 ? fallback : self }
}
