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
    @State private var navigateToPractice = false

    private var user: User? { store.user }
    private var streak: Int { user?.currentStreak ?? 0 }
    private var level: Int { user?.level ?? 1 }
    private var totalXP: Int { user?.totalXP ?? 0 }

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
                            Text("Namaste,")
                                .font(.system(size: 18))
                                .foregroundColor(.skySub)
                            Text(user?.username ?? "Practitioner")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.skyText)
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
                                        .frame(width: geo.size.width * xpProgress, height: 10)
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
                                    Text("Ready for SKY?")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Guided Daily Practice • 35m")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            .padding(25)
                            .background(Color.skyIndigo)
                            .cornerRadius(20)
                            .shadow(color: Color.skyIndigo.opacity(0.3), radius: 10, y: 4)
                        }

                        // Journey card
                        Text("Your Journey")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.skyText)

                        Text("You've completed the SKY Breath Meditation course. Keep the momentum going to experience deep rest and clarity.")
                            .font(.system(size: 15))
                            .foregroundColor(Color(red: 67/255, green: 56/255, blue: 202/255))
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.skyIndigoLight)
                            .cornerRadius(20)

                        // Milestone card
                        if let m = activeMilestone {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(m.title).font(.system(size: 16, weight: .bold)).foregroundColor(.skyIndigo)
                                Text(m.body).font(.system(size: 14)).foregroundColor(.skySub).lineSpacing(4)
                                Text(m.teacher).font(.caption).foregroundColor(.skyMuted)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(Rectangle().fill(Color.skyIndigo).frame(width: 4), alignment: .leading)
                            .cornerRadius(16)
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
            .navigationBarHidden(true)
            .task { await store.refreshUser() }
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
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
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
                    .background(Color.skyIndigo).cornerRadius(10)
            }
            Button("Remind me later", action: onDismiss)
                .font(.system(size: 13)).foregroundColor(.skyMuted).frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(red: 254/255, green: 249/255, blue: 195/255))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 253/255, green: 230/255, blue: 138/255), lineWidth: 1))
    }
}
