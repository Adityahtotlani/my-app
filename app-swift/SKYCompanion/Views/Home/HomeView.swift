import SwiftUI

private struct Milestone {
    let minStreak: Int
    let title: String
    let body: String
    let teacher: String
}

private let milestones: [Milestone] = [
    Milestone(minStreak: 90, title: "You're a Practitioner Now ✦",
              body: "90 days. You've earned the title. Consider deepening your practice with Part 2.",
              teacher: "Art of Living Foundation"),
    Milestone(minStreak: 40, title: "The 40-Day Transformation ✦",
              body: "40 days of consistent practice creates lasting physiological change. Welcome to the other side.",
              teacher: "Bhanu Narasimhan, Sr. Teacher"),
    Milestone(minStreak: 21, title: "21 Days — You've built a habit ✦",
              body: "Neuroscience confirms: 21 days is when new neural pathways stabilise. You're there.",
              teacher: "Dinesh K., AoL Faculty"),
    Milestone(minStreak: 7,  title: "You've built your first week ✦",
              body: "The first week is the hardest. Your body is learning a new rhythm. Keep going.",
              teacher: "Ravi Shankar, Sr. Teacher"),
]

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var retreatDismissed = false
    @State private var xpBarVisible = false

    private var user: User? { store.user }
    private var streak: Int  { user?.currentStreak ?? store.localCurrentStreak }
    private var level: Int   { user?.level ?? store.localLevel }
    private var totalXP: Int { user?.totalXP ?? store.localTotalXP }

    private var practicedToday: Bool {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return store.localPracticedDates.contains(f.string(from: Date()))
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning,"
        case 12..<17: return "Good afternoon,"
        default:     return "Good evening,"
        }
    }

    private var activeMilestone: Milestone? { milestones.first { streak >= $0.minStreak } }
    private var nextMilestone: Milestone?   { milestones.last  { streak < $0.minStreak }  }

    private var minutesThisWeek: Int {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        guard let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: today) else { return 0 }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return store.localSessions.filter {
            guard let d = f.date(from: $0.date) else { return false }
            return cal.startOfDay(for: d) >= cal.startOfDay(for: monday)
        }.reduce(0) { $0 + $1.durationSeconds / 60 }
    }

    private var sessionsThisWeek: Int {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        guard let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: today) else { return 0 }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return store.localSessions.filter {
            guard let d = f.date(from: $0.date) else { return false }
            return cal.startOfDay(for: d) >= cal.startOfDay(for: monday)
        }.count
    }

    private var xpProgress: Double {
        guard level < 6 else { return 1.0 }
        let prev = levelThresholds[level - 1]
        let next = levelThresholds[level]
        return min(1.0, Double(totalXP - prev) / Double(next - prev))
    }

    private var levelName: String {
        let names = ["", "Seeker", "Practitioner", "Steady Breather", "Inner Circle", "SKY Guide", "Luminous"]
        return names.indices.contains(level) ? names[level] : "Seeker"
    }

    private var shareText: String {
        streak > 0
            ? "I've been practicing SKY Breath Meditation for \(streak) day\(streak == 1 ? "" : "s") straight 🔥 – tracking my journey with SKY Companion."
            : "Just started my SKY Breath Meditation journey with SKY Companion ✨"
    }

    private var xpToNext: Int {
        guard level < 6 else { return 0 }
        return levelThresholds[level] - totalXP
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting)
                                    .font(.subheadline)
                                    .foregroundColor(.skySub)
                                Text(user?.username ?? (store.localName.isEmpty ? "Practitioner" : store.localName))
                                    .font(.largeTitle.weight(.heavy))
                                    .foregroundColor(.skyText)
                                if let intention = store.intention, !intention.isEmpty {
                                    Label("Practicing for: \(intention)", systemImage: "leaf.fill")
                                        .font(.caption)
                                        .foregroundColor(.skySub)
                                        .padding(.top, 2)
                                }
                            }
                            Spacer()
                            // 44×44 tap target per HIG
                            ShareLink(item: shareText) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.skyIndigo)
                                    .frame(width: 44, height: 44)
                                    .background(Color.skyIndigoLight)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Share streak")
                            .padding(.top, 6)
                        }
                        .padding(.top, 8)

                        // Stats row
                        HStack(spacing: 15) {
                            StatCard(icon: "flame.fill", iconColor: .red, value: "\(streak)", label: "Day Streak",
                                     subtitle: store.localMaxStreak > streak && store.localMaxStreak > 0
                                         ? "Best: \(store.localMaxStreak) days" : nil)
                            StatCard(icon: "trophy.fill", iconColor: .yellow, value: "\(level)", label: "Level",
                                     subtitle: levelName)
                        }

                        // XP bar
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "star.fill").foregroundColor(.skyIndigo)
                                Text("Total XP: \(totalXP)")
                                    .font(.headline)
                                    .foregroundColor(.skyText)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)).frame(height: 10)
                                    RoundedRectangle(cornerRadius: 5).fill(Color.skyIndigo)
                                        .frame(width: geo.size.width * (xpBarVisible ? xpProgress : 0), height: 10)
                                        .animation(.spring(response: 1.0, dampingFraction: 0.85), value: xpBarVisible)
                                        .animation(.easeOut(duration: 0.5), value: xpProgress)
                                }
                            }
                            .frame(height: 10)
                            Text(level >= 6 ? "Max Level — Luminous" : "\(xpToNext) XP to Level \(level + 1)")
                                .font(.caption)
                                .foregroundColor(.skyMuted)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .skyCard()

                        // Practice CTA
                        NavigationLink(destination: PracticeView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(practicedToday ? "Session Complete ✓" : "Ready for SKY?")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.white)
                                    Text(practicedToday ? "Practice again anytime" : "Guided Daily Practice • 35m")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: practicedToday ? "checkmark.circle.fill" : "arrow.right")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            .padding(25)
                            .background(practicedToday
                                ? Color(red: 16/255, green: 185/255, blue: 129/255)
                                : Color.skyIndigo)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(
                                color: (practicedToday
                                    ? Color(red: 16/255, green: 185/255, blue: 129/255)
                                    : Color.skyIndigo).opacity(0.3),
                                radius: 10, y: 4)
                        }
                        .animation(.easeInOut(duration: 0.3), value: practicedToday)

                        // Today's session recap
                        if let session = store.todaySession {
                            TodaySessionCard(session: session)
                                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                                .animation(.easeOut(duration: 0.35), value: practicedToday)
                        }

                        // Streak at risk warning
                        if store.localStreakAtRisk {
                            HStack(spacing: 12) {
                                Text("🔥").font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Streak at Risk!")
                                        .font(.footnote.weight(.bold))
                                        .foregroundColor(Color(red: 154/255, green: 52/255, blue: 18/255))
                                    Text("Practice today to keep your \(streak)-day streak.")
                                        .font(.footnote)
                                        .foregroundColor(Color(red: 154/255, green: 52/255, blue: 18/255).opacity(0.75))
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(Color(red: 254/255, green: 243/255, blue: 199/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(red: 251/255, green: 191/255, blue: 36/255), lineWidth: 1)
                            }
                        }

                        // First-session welcome card
                        if store.localSessions.isEmpty { FirstSessionCard() }

                        // This Week strip
                        HStack(alignment: .firstTextBaseline) {
                            Text("This Week")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.skyText)
                            Spacer()
                            if minutesThisWeek > 0 {
                                Text("\(sessionsThisWeek) session\(sessionsThisWeek == 1 ? "" : "s") · \(minutesThisWeek) min")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(.skyIndigo)
                            }
                        }

                        WeekStripView(practicedDates: store.localPracticedDates, weeklyGoal: store.weeklyGoal)

                        // Milestone card
                        if let m = activeMilestone {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(m.title).font(.callout.weight(.bold)).foregroundColor(.skyIndigo)
                                Text(m.body).font(.footnote).foregroundColor(.skySub).lineSpacing(4)
                                Text(m.teacher).font(.caption).foregroundColor(.skyMuted)
                            }
                            .padding(16)
                            .overlay(alignment: .leading) {
                                Rectangle().fill(Color.skyIndigo).frame(width: 4)
                            }
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        }

                        // Next milestone teaser
                        if let next = nextMilestone, streak > 0 {
                            let remaining = next.minStreak - streak
                            HStack(spacing: 10) {
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.skyIndigo)
                                    .font(.footnote)
                                (Text("\(remaining) day\(remaining == 1 ? "" : "s") to ")
                                    .font(.footnote)
                                    .foregroundColor(.skySub)
                                + Text(next.title.replacingOccurrences(of: " ✦", with: ""))
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(.skyIndigo))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.skyIndigoLight)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Retreat banner
                        if streak >= 30 && !retreatDismissed {
                            RetreatBanner(onDismiss: { retreatDismissed = true })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .refreshable {
                    await store.refreshUser()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await store.refreshUser()
                try? await Task.sleep(for: .milliseconds(200))
                xpBarVisible = true
            }
        }
    }
}

private struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(iconColor).font(.title)
            Text(value).font(.title2.weight(.bold)).foregroundColor(.skyText)
            Text(label).font(.caption).foregroundColor(.skySub)
            if let sub = subtitle {
                Text(sub).font(.caption2).foregroundColor(.skyMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}

private struct WeekStripView: View {
    let practicedDates: Set<String>
    let weeklyGoal: Int

    private let formatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    private var weekDays: [(date: Date, label: String)] {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        guard let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }
        let letters = ["M","T","W","T","F","S","S"]
        return (0..<7).compactMap { offset -> (Date, String)? in
            guard let d = cal.date(byAdding: .day, value: offset, to: monday) else { return nil }
            return (d, letters[offset])
        }
    }

    private var practicedThisWeek: Int {
        weekDays.filter { practicedDates.contains(formatter.string(from: $0.date)) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if practicedThisWeek >= weeklyGoal {
                Label("Goal reached! \(practicedThisWeek) of \(weeklyGoal) days", systemImage: "checkmark.circle.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
            } else {
                Text("Practiced \(practicedThisWeek) of \(weeklyGoal) days")
                    .font(.footnote)
                    .foregroundColor(.skySub)
            }

            HStack(spacing: 6) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { _, entry in
                    let key = formatter.string(from: entry.date)
                    let practiced = practicedDates.contains(key)
                    let isToday = Calendar.current.isDateInToday(entry.date)
                    let isFuture = entry.date > Date()

                    VStack(spacing: 6) {
                        Text(entry.label)
                            .font(isToday ? .caption2.weight(.bold) : .caption2)
                            .foregroundColor(isToday ? .skyIndigo : .skyMuted)

                        ZStack {
                            Circle()
                                .fill(practiced
                                    ? Color.skyIndigo
                                    : isFuture ? Color.clear : Color(UIColor.systemGray5))
                                .frame(width: 34, height: 34)
                            if isToday && !practiced {
                                Circle().stroke(Color.skyIndigo, lineWidth: 2).frame(width: 34, height: 34)
                            }
                            if practiced {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .skyCard()
    }
}

private struct FirstSessionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Your Journey Starts Here", systemImage: "wind")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.skyIndigo)
            Text("Your first SKY session takes about 35 minutes and guides you through 5 breathing phases. Even one session creates measurable change in your nervous system.")
                .font(.footnote)
                .foregroundColor(.skySub)
                .lineSpacing(3)
            HStack(spacing: 8) {
                ForEach(["35 min", "5 phases", "Eyes closed"], id: \.self) { tip in
                    Text(tip)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.skyIndigo)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.skyIndigoLight)
                        .clipShape(Capsule())
                }
            }
        }
        .skyCard()
    }
}

private struct RetreatBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ready to go deeper?")
                .font(.callout.weight(.bold)).foregroundColor(.skyText)
            Text("You've practiced 30 days in a row. The AoL Part 2 retreat is where the next transformation happens.")
                .font(.footnote).foregroundColor(.skySub).lineSpacing(4)
            Link(destination: URL(string: "https://www.artofliving.org/us-en/advance-meditation-course")!) {
                Text("Browse Upcoming Retreats")
                    .font(.footnote.weight(.semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(12)
                    .background(Color.skyIndigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Button("Remind me later", action: onDismiss)
                .font(.footnote).foregroundColor(.skyMuted).frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(red: 254/255, green: 249/255, blue: 195/255))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(Color(red: 253/255, green: 230/255, blue: 138/255), lineWidth: 1)
        }
    }
}

private struct TodaySessionCard: View {
    let session: LocalSession

    private var moodEmoji: String? {
        guard let score = session.moodScore else { return nil }
        let emojis = ["", "😔", "😕", "😐", "🙂", "😊"]
        return emojis.indices.contains(score) ? emojis[score] : nil
    }

    private var xpEarned: Int { session.type == "full" ? 100 : 50 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Today's Practice", systemImage: "checkmark.circle.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
                Spacer()
                Text("+\(xpEarned) XP")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.skyIndigo)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.skyIndigoLight)
                    .clipShape(Capsule())
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(session.durationSeconds / 60) min")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.skyText)
                    Text(session.type == "full" ? "Full session" : "Short session")
                        .font(.caption)
                        .foregroundColor(.skySub)
                }
                if let emoji = moodEmoji {
                    Divider().frame(height: 36)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(emoji).font(.title2)
                        Text("Mood").font(.caption).foregroundColor(.skySub)
                    }
                }
                Spacer()
            }

            if let note = session.note, !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundColor(.skySub)
                    .lineLimit(2)
                    .lineSpacing(3)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .skyCard()
    }
}
