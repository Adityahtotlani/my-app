import SwiftUI
import Charts

struct ProgressView_: View {
    @EnvironmentObject var store: AppStore
    @State private var sessions: [Session] = []
    @State private var practicedDates: Set<String> = []
    @State private var moodTrend: [MoodPoint] = []
    @State private var isLoading = true
    @State private var selectedSession: Session?
    @State private var showAllSessions = false

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
    private var totalPracticeTime: String {
        let secs = sessions.reduce(0) { $0 + $1.durationSeconds }
        let h = secs / 3600; let m = (secs % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return m == 0 ? "—" : "\(m)m"
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
                                .font(.largeTitle.weight(.heavy))
                                .foregroundColor(.skyText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            StreakCalendarView(practicedDates: practicedDates).skyCard()

                            // Mood chart
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Mood Trend (Last 14 Sessions)")
                                    .font(.callout.weight(.bold)).foregroundColor(.skySub)

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
                                                        Text(emojis[idx]).font(.caption)
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
                                    .font(.callout.weight(.bold)).foregroundColor(.skySub)

                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Lvl \(level)")
                                        .font(.title2.weight(.heavy)).foregroundColor(.skyIndigo)
                                    Text(levelName)
                                        .font(.headline).foregroundColor(.skyText)
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

                            if sessions.isEmpty { EmptyProgressCard() }

                            // Stats 2×2 grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                MiniStatCard(label: "Total Sessions", value: sessions.isEmpty ? "—" : "\(sessions.count)")
                                MiniStatCard(label: "Total Hours",    value: totalPracticeTime)
                                MiniStatCard(label: "Avg. Duration",  value: avgDurationMins == 0 ? "—" : "\(avgDurationMins)m")
                                MiniStatCard(label: "Personal Best",  value: personalBest == 0 ? "—" : "\(personalBest) days")
                            }

                            // Session history
                            if !sessions.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Sessions")
                                            .font(.callout.weight(.bold))
                                            .foregroundColor(.skySub)
                                        Spacer()
                                        Text("\(sessions.count) total")
                                            .font(.caption)
                                            .foregroundColor(.skyMuted)
                                    }

                                    let displayed = Array(sessions.reversed()
                                        .prefix(showAllSessions ? sessions.count : 5))
                                    VStack(spacing: 8) {
                                        ForEach(displayed) { session in
                                            Button { selectedSession = session } label: {
                                                SessionRow(session: session)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }

                                    if sessions.count > 5 {
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                showAllSessions.toggle()
                                            }
                                        } label: {
                                            Text(showAllSessions
                                                 ? "Show less"
                                                 : "Show all \(sessions.count) sessions")
                                                .font(.footnote.weight(.medium))
                                                .foregroundColor(.skyIndigo)
                                                .frame(maxWidth: .infinity)
                                                .padding(.top, 4)
                                        }
                                    }
                                }
                                .skyCard()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .refreshable {
                        if !store.token.isEmpty { await store.refreshUser() }
                        sessions       = store.localSessionsAsSessions
                        practicedDates = store.localPracticedDates
                        moodTrend      = store.localMoodTrend
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await loadAll() }
            .onChange(of: store.localSessions.count) { _ in
                Task { await loadAll() }
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailSheet(session: session)
                    .presentationDragIndicator(.visible)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(session.type == "full" ? "Full" : "Short")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(session.type == "full" ? .skyIndigo : Color(red: 22/255, green: 163/255, blue: 74/255))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(session.type == "full"
                        ? Color.skyIndigoLight
                        : Color(red: 240/255, green: 253/255, blue: 244/255))
                    .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedDate)
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.skyText)
                    Text("\(session.durationSeconds / 60)m")
                        .font(.caption)
                        .foregroundColor(.skyMuted)
                }

                Spacer()

                if !moodEmoji.isEmpty {
                    Text(moodEmoji).font(.title3)
                }
            }

            if let note = session.note, !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundColor(.skySub)
                    .lineLimit(2)
                    .padding(.leading, 4)
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
            Text(label).font(.caption2).foregroundColor(.skySub).multilineTextAlignment(.center)
            Text(value).font(.title2.weight(.bold)).foregroundColor(.skyText)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}

private struct SessionDetailSheet: View {
    let session: Session
    @Environment(\.dismiss) var dismiss

    private var moodLabel: String {
        switch session.moodScore {
        case 1: return "😔  Tough"
        case 2: return "😕  Low"
        case 3: return "😐  Okay"
        case 4: return "🙂  Good"
        case 5: return "😊  Great"
        default: return ""
        }
    }

    private var formattedDate: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: session.completedAt) else { return session.completedAt }
        let out = DateFormatter(); out.dateStyle = .long; out.timeStyle = .none
        return out.string(from: date)
    }

    private var xpEarned: Int { session.type == "full" ? 100 : 50 }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(session.type == "full" ? "Full Session" : "Short Session")
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(session.type == "full"
                                    ? .skyIndigo
                                    : Color(red: 22/255, green: 163/255, blue: 74/255))
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(session.type == "full"
                                    ? Color.skyIndigoLight
                                    : Color(red: 240/255, green: 253/255, blue: 244/255))
                                .clipShape(Capsule())
                            Spacer()
                        }

                        Text(formattedDate)
                            .font(.title.weight(.heavy))
                            .foregroundColor(.skyText)

                        HStack(spacing: 12) {
                            DetailStatPill(icon: "clock",      label: "Duration",  value: "\(session.durationSeconds / 60) min")
                            DetailStatPill(icon: "star.fill",  label: "XP Earned", value: "+\(xpEarned) XP")
                        }

                        if !moodLabel.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Mood After Practice")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(.skySub)
                                Text(moodLabel).font(.title2)
                            }
                            .skyCard()
                        }

                        if let note = session.note, !note.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Reflection", systemImage: "quote.opening")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(.skyIndigo)
                                Text(note)
                                    .font(.subheadline)
                                    .foregroundColor(.skyText)
                                    .lineSpacing(5)
                            }
                            .skyCard()
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Session Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.skyIndigo)
                }
            }
        }
    }
}

private struct EmptyProgressCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wind").font(.largeTitle).foregroundColor(.skyIndigo)
            Text("Your journey begins here")
                .font(.headline)
                .foregroundColor(.skyText)
            Text("Complete your first SKY session to start tracking your streak, mood, and progress over time.")
                .font(.footnote)
                .foregroundColor(.skySub)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Text("Head to the Practice tab to begin →")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.skyIndigo)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.skyIndigoLight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.skyIndigo.opacity(0.08), radius: 10, y: 2)
    }
}

private struct DetailStatPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(.skyIndigo).font(.headline)
            Text(value).font(.callout.weight(.bold)).foregroundColor(.skyText)
            Text(label).font(.caption).foregroundColor(.skySub)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}
