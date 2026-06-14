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

    private var activeMilestone: Milestone? {
        milestones.first { streak >= $0.minStreak }
    }

    private var xpProgress: Double {
        guard level < 6 else { return 1.0 }
        let prev = levelThresholds[level - 1]
        let next = levelThresholds[level]
        return min(1.0, Double(totalXP - prev) / Double(next - prev))
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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.system(size: 15))
                                .foregroundColor(.skySub)
                            Text(user?.username ?? (store.localName.isEmpty ? "Practitioner" : store.localName))
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.skyText)
                            if let intention = store.intention, !intention.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.skyIndigo)
                                    Text("Practicing for: \(intention)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.skySub)
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(.top, 8)

                        // Stats row
                        HStack(spacing: 15) {
                            StatCard(icon: "flame.fill", iconColor: .red, value: "\(streak)", label: "Day Streak")
                            StatCard(icon: "trophy.fill", iconColor: .yellow, value: "\(level)", label: "Level")
                        }

                        // XP bar
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "star.fill").foregroundColor(.skyIndigo)
                                Text("Total XP: \(totalXP)")
                                    .font(.system(size: 17, weight: .bold))
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
                                        .font(.system(size: 20, weight: .bold))
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

                        // Streak at risk warning
                        if store.localStreakAtRisk {
                            HStack(spacing: 12) {
                                Text("🔥")
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Streak at Risk!")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(red: 154/255, green: 52/255, blue: 18/255))
                                    Text("Practice today to keep your \(streak)-day streak.")
                                        .font(.system(size: 13))
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
                        if store.localSessions.isEmpty {
                            FirstSessionCard()
                        }

                        // This Week strip
                        Text("This Week")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.skyText)

                        WeekStripView(practicedDates: store.localPracticedDates)

                        // Milestone card
                        if let m = activeMilestone {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(m.title).font(.system(size: 16, weight: .bold)).foregroundColor(.skyIndigo)
                                Text(m.body).font(.system(size: 14)).foregroundColor(.skySub).lineSpacing(4)
                                Text(m.teacher).font(.caption).foregroundColor(.skyMuted)
                            }
                            .padding(16)
                            .overlay(alignment: .leading) {
                                Rectangle().fill(Color.skyIndigo).frame(width: 4)
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        }

                        // Retreat banner
                        if streak >= 30 && !retreatDismissed {
                            RetreatBanner(onDismiss: { retreatDismissed = true })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
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

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(iconColor).font(.title)
            Text(value).font(.system(size: 24, weight: .bold)).foregroundColor(.skyText)
            Text(label).font(.caption).foregroundColor(.skySub)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}

private struct WeekStripView: View {
    let practicedDates: Set<String>

    private let formatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    // Monday-anchored week days
    private var weekDays: [(date: Date, label: String)] {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today) // 1=Sun…7=Sat
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
            HStack {
                Text("Practiced \(practicedThisWeek) of 7 days")
                    .font(.system(size: 13))
                    .foregroundColor(.skySub)
                Spacer()
            }

            HStack(spacing: 6) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { _, entry in
                    let key = formatter.string(from: entry.date)
                    let practiced = practicedDates.contains(key)
                    let isToday = Calendar.current.isDateInToday(entry.date)
                    let isFuture = entry.date > Date()

                    VStack(spacing: 6) {
                        Text(entry.label)
                            .font(.system(size: 11, weight: isToday ? .bold : .regular))
                            .foregroundColor(isToday ? .skyIndigo : .skyMuted)

                        ZStack {
                            Circle()
                                .fill(practiced
                                    ? Color.skyIndigo
                                    : isFuture ? Color.clear : Color(UIColor.systemGray5))
                                .frame(width: 34, height: 34)

                            if isToday && !practiced {
                                Circle()
                                    .stroke(Color.skyIndigo, lineWidth: 2)
                                    .frame(width: 34, height: 34)
                            }

                            if practiced {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.skyIndigo)

            Text("Your first SKY session takes about 35 minutes and guides you through 5 breathing phases. Even one session creates measurable change in your nervous system.")
                .font(.system(size: 14))
                .foregroundColor(.skySub)
                .lineSpacing(3)

            HStack(spacing: 8) {
                ForEach(["35 min", "5 phases", "Eyes closed"], id: \.self) { tip in
                    Text(tip)
                        .font(.system(size: 11, weight: .semibold))
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
                .font(.system(size: 16, weight: .bold)).foregroundColor(.skyText)
            Text("You've practiced 30 days in a row. The AoL Part 2 retreat is where the next transformation happens.")
                .font(.system(size: 14)).foregroundColor(.skySub).lineSpacing(4)
            Link(destination: URL(string: "https://www.artofliving.org/us-en/advance-meditation-course")!) {
                Text("Browse Upcoming Retreats")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(12)
                    .background(Color.skyIndigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Button("Remind me later", action: onDismiss)
                .font(.system(size: 13)).foregroundColor(.skyMuted).frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(red: 254/255, green: 249/255, blue: 195/255))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(Color(red: 253/255, green: 230/255, blue: 138/255), lineWidth: 1)
        }
    }
}
