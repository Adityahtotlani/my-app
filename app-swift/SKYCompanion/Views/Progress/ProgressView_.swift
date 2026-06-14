import SwiftUI
import Charts

struct ProgressView_: View {
    @EnvironmentObject var store: AppStore
    @State private var sessions: [Session] = []
    @State private var practicedDates: Set<String> = []
    @State private var moodTrend: [MoodPoint] = []
    @State private var isLoading = true

    private var user: User? { store.user }
    private var level: Int   { user?.level ?? store.localLevel }
    private var totalXP: Int { user?.totalXP ?? store.localTotalXP }

    private var xpProgress: Double {
        guard level < 6 else { return 1.0 }
        let prev = levelThresholds[level - 1]
        let next = levelThresholds[level]
        return min(1.0, Double(totalXP - prev) / Double(next - prev))
    }

    private var levelNames: [String] {
        ["", "Seeker", "Practitioner", "Steady Breather", "Inner Circle", "SKY Guide", "Luminous"]
    }
    private var levelName: String { levelNames.indices.contains(level) ? levelNames[level] : "Seeker" }
    private var avgDurationMins: Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.durationSeconds } / sessions.count / 60
    }
    private var personalBest: Int { user?.maxStreak ?? store.localMaxStreak }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                if isLoading {
                    ProgressView().tint(.skyIndigo)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Your Progress")
                                .font(.system(size: 28, weight: .heavy)).foregroundColor(.skyText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Streak calendar
                            StreakCalendarView(practicedDates: practicedDates).skyCard()

                            // Mood chart
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Mood Trend (Last 14 Sessions)")
                                    .font(.system(size: 16, weight: .bold)).foregroundColor(.skySub)

                                if moodTrend.isEmpty {
                                    Text("Select a mood after each session to track your trend.")
                                        .font(.subheadline).foregroundColor(.skyMuted)
                                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                                } else {
                                    Chart(moodTrend) { point in
                                        LineMark(x: .value("Day", point.day), y: .value("Mood", point.mood))
                                            .foregroundStyle(Color(red: 16/255, green: 185/255, blue: 129/255))
                                            .interpolationMethod(.catmullRom)
                                        AreaMark(x: .value("Day", point.day), y: .value("Mood", point.mood))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.2), .clear],
                                                    startPoint: .top, endPoint: .bottom)
                                            )
                                            .interpolationMethod(.catmullRom)
                                        PointMark(x: .value("Day", point.day), y: .value("Mood", point.mood))
                                            .foregroundStyle(Color(red: 16/255, green: 185/255, blue: 129/255))
                                            .symbolSize(30)
                                    }
                                    .chartYScale(domain: 1...5)
                                    .chartYAxis {
                                        AxisMarks(values: [1.0, 2.0, 3.0, 4.0, 5.0]) { value in
                                            AxisGridLine().foregroundStyle(Color(UIColor.systemGray5))
                                            AxisValueLabel {
                                                let emojis = ["😔", "😕", "😐", "🙂", "😊"]
                                                if let v = value.as(Double.self) {
                                                    let idx = Int(v) - 1
                                                    if emojis.indices.contains(idx) {
                                                        Text(emojis[idx]).font(.system(size: 14))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .chartXAxis(.hidden)
                                    .frame(height: 180)
                                }
                            }
                            .skyCard()

                            // XP / Level
                            VStack(alignment: .leading, spacing: 12) {
                                Text("XP & Level")
                                    .font(.system(size: 16, weight: .bold)).foregroundColor(.skySub)

                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Lvl \(level)")
                                        .font(.system(size: 22, weight: .heavy)).foregroundColor(.skyIndigo)
                                    Text(levelName)
                                        .font(.system(size: 18, weight: .semibold)).foregroundColor(.skyText)
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)).frame(height: 10)
                                        RoundedRectangle(cornerRadius: 5).fill(Color.skyIndigo)
                                            .frame(width: geo.size.width * xpProgress, height: 10)
                                    }
                                }
                                .frame(height: 10)

                                HStack {
                                    Text("\(totalXP) XP").font(.caption).foregroundColor(.skyMuted)
                                    Spacer()
                                    if level >= 6 {
                                        Text("Max Level").font(.caption).foregroundColor(.skyMuted)
                                    } else {
                                        Text("\(levelThresholds[level] - totalXP) XP to next level")
                                            .font(.caption).foregroundColor(.skyMuted)
                                    }
                                }
                            }
                            .skyCard()

                            // Stats row
                            HStack(spacing: 12) {
                                MiniStatCard(label: "Total Sessions", value: "\(sessions.count)")
                                MiniStatCard(label: "Avg. Duration",  value: "\(avgDurationMins)m")
                                MiniStatCard(label: "Personal Best",  value: "\(personalBest) days")
                            }

                            // Recent sessions
                            if !sessions.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Sessions")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.skySub)

                                    VStack(spacing: 8) {
                                        ForEach(sessions.reversed().prefix(5)) { session in
                                            SessionRow(session: session)
                                        }
                                    }
                                }
                                .skyCard()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await loadAll() }
            .onChange(of: store.localSessions.count) { _ in
                Task { await loadAll() }
            }
        }
    }

    private func loadAll() async {
        isLoading = true

        guard !store.token.isEmpty else {
            sessions       = store.localSessionsAsSessions
            practicedDates = store.localPracticedDates
            moodTrend      = store.localMoodTrend
            isLoading = false
            return
        }

        await store.refreshUser()
        async let s = try? store.fetchHistory()
        async let d = try? store.fetchStreakCalendar()
        async let m = try? store.fetchMoodTrend()

        let apiSessions = await s ?? []
        sessions       = apiSessions.isEmpty ? store.localSessionsAsSessions : apiSessions

        let apiDates   = await d ?? []
        practicedDates = apiDates.isEmpty ? store.localPracticedDates : Set(apiDates)

        let apiMood    = await m ?? []
        moodTrend      = apiMood.isEmpty ? store.localMoodTrend : apiMood

        isLoading = false
    }
}

private struct SessionRow: View {
    let session: Session

    private var moodEmoji: String {
        switch session.moodScore {
        case 1: return "😔"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return ""
        }
    }

    private var formattedDate: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: session.completedAt) else { return session.completedAt }
        let out = DateFormatter(); out.dateStyle = .medium; out.timeStyle = .none
        return out.string(from: date)
    }

    private var duration: String {
        "\(session.durationSeconds / 60)m"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Type badge
            Text(session.type == "full" ? "Full" : "Short")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(session.type == "full" ? .skyIndigo : Color(red: 22/255, green: 163/255, blue: 74/255))
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(session.type == "full"
                    ? Color.skyIndigoLight
                    : Color(red: 240/255, green: 253/255, blue: 244/255))
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.skyText)
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.skyMuted)
            }

            Spacer()

            if !moodEmoji.isEmpty {
                Text(moodEmoji).font(.system(size: 20))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.5)
        }
    }
}

private struct MiniStatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(label).font(.system(size: 11)).foregroundColor(.skySub).multilineTextAlignment(.center)
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.skyText)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}
