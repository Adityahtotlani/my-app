import SwiftUI
import Charts

struct ProgressView_: View {
    @EnvironmentObject var store: AppStore
    @State private var sessions: [Session] = []
    @State private var practicedDates: Set<String> = []
    @State private var moodTrend: [MoodPoint] = []
    @State private var isLoading = true

    private var user: User? { store.user }
    private var level: Int { user?.level ?? 1 }
    private var totalXP: Int { user?.totalXP ?? 0 }

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
                                    Text("No mood data yet. Log some sessions to see your trend.")
                                        .font(.subheadline).foregroundColor(.skyMuted)
                                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                                } else {
                                    Chart(moodTrend) { point in
                                        LineMark(x: .value("Day", point.day), y: .value("Mood", point.mood))
                                            .foregroundStyle(Color(red: 16/255, green: 185/255, blue: 129/255))
                                            .interpolationMethod(.catmullRom)
                                        AreaMark(x: .value("Day", point.day), y: .value("Mood", point.mood))
                                            .foregroundStyle(
                                                LinearGradient(colors: [Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.2), .clear],
                                                               startPoint: .top, endPoint: .bottom)
                                            )
                                            .interpolationMethod(.catmullRom)
                                    }
                                    .chartYScale(domain: 1...5)
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
                                        Text("\(levelThresholds[level]) XP to next level").font(.caption).foregroundColor(.skyMuted)
                                    }
                                }
                            }
                            .skyCard()

                            // Stats row
                            HStack(spacing: 12) {
                                MiniStatCard(label: "Total Sessions", value: "\(sessions.count)")
                                MiniStatCard(label: "Avg. Duration", value: "\(avgDurationMins)m")
                                MiniStatCard(label: "Personal Best", value: "\(user?.maxStreak ?? 0) days")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .task { await loadAll() }
        }
    }

    private func loadAll() async {
        isLoading = true
        await store.refreshUser()
        async let s = try? store.fetchHistory()
        async let d = try? store.fetchStreakCalendar()
        async let m = try? store.fetchMoodTrend()
        sessions        = await s ?? []
        practicedDates  = Set(await d ?? [])
        moodTrend       = await m ?? []
        isLoading = false
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
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}
