import SwiftUI

private let moods: [(emoji: String, score: Int)] = [
    ("😔", 1), ("😕", 2), ("😐", 3), ("🙂", 4), ("😊", 5)
]

private let insights = [
    "Your HRV improves within minutes of rhythmic breathing.",
    "SKY breathing activates the parasympathetic nervous system.",
    "Slow breath at 5 breaths/min maximises vagal tone.",
    "Post-session rest consolidates neuroplasticity gains.",
    "Coherent breathing synchronises heart and brain rhythms.",
]

struct PostSessionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    let sessionType: String
    let durationSeconds: Int

    private let insight = insights.randomElement()!
    private var xpEarned: Int { sessionType == "full" ? 100 : 50 }

    @State private var showCelebration = false
    @State private var celebrationStreak = 0
    @State private var note: String = ""
    @State private var newLevel: Int? = nil
    @State private var newAchievement: Achievement? = nil

    var body: some View {
        ZStack {
            Color.skyBg.ignoresSafeArea()

            if showCelebration {
                celebrationView
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                summaryView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: showCelebration)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Summary screen

    private var summaryView: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Session Complete")
                .font(.title.weight(.bold))
                .foregroundColor(.skyText)

            // Summary card
            VStack(alignment: .leading, spacing: 12) {
                Text("SUMMARY")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.skySub).kerning(0.5)

                HStack {
                    VStack(spacing: 4) {
                        Text(formatDuration(durationSeconds))
                            .font(.title2.weight(.bold)).foregroundColor(.skyIndigo)
                        Text("Duration").font(.caption).foregroundColor(.skyMuted)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40)

                    VStack(spacing: 4) {
                        Text("+\(xpEarned) XP")
                            .font(.title2.weight(.bold)).foregroundColor(.skyIndigo)
                        Text("Earned").font(.caption).foregroundColor(.skyMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .skyCard()

            // Insight card
            VStack(alignment: .leading, spacing: 8) {
                Text("SCIENCE INSIGHT")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.skyIndigo).kerning(0.5)
                Text(insight)
                    .font(.subheadline)
                    .foregroundColor(.skyText)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.skyIndigoLight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 2)

            // Reflection field
            VStack(alignment: .leading, spacing: 8) {
                Text("Reflection")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.skySub)
                TextField("How was your practice today? (optional)", text: $note, axis: .vertical)
                    .font(.footnote)
                    .foregroundColor(.skyText)
                    .lineLimit(3...5)
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    }
            }

            // Mood picker
            VStack(spacing: 16) {
                Text("How do you feel?")
                    .font(.headline)
                    .foregroundColor(.skyText)

                HStack(spacing: 12) {
                    ForEach(moods, id: \.score) { mood in
                        Button {
                            Task { await handleMood(score: mood.score) }
                        } label: {
                            Text(mood.emoji).font(.title2)
                                .frame(width: 56, height: 56)
                                .background(Color(UIColor.secondarySystemBackground))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                        }
                    }
                }

                Button("Skip") { Task { await handleSkip() } }
                    .font(.footnote)
                    .foregroundColor(.skyMuted)
                    .padding(.top, 4)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Celebration screen

    private var celebrationView: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(newLevel != nil ? "🏆" : (celebrationStreak > 1 ? "🔥" : "✨"))
                .font(.system(size: 80))
                .padding(.bottom, 16)

            Group {
                if let lvl = newLevel {
                    VStack(spacing: 4) {
                        Text("Level Up!")
                            .font(.largeTitle.weight(.heavy))
                            .foregroundColor(.skyIndigo)
                        Text(levelName(for: lvl))
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.skySub)
                    }
                } else {
                    Text(celebrationStreak > 0
                         ? "\(celebrationStreak) Day\(celebrationStreak == 1 ? "" : "s") Streak!"
                         : "Session Logged!")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundColor(.skyText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.bottom, 8)

            Text(celebrationSubline)
                .font(.callout)
                .foregroundColor(.skySub)
                .padding(.bottom, 24)

            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("+\(xpEarned) XP Earned")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(Color(red: 67/255, green: 56/255, blue: 202/255))
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(Color.skyIndigoLight)
            .clipShape(Capsule())

            if let badge = newAchievement {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.skyIndigoLight).frame(width: 42, height: 42)
                        Image(systemName: badge.icon)
                            .foregroundColor(.skyIndigo).font(.headline)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACHIEVEMENT UNLOCKED")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.skyIndigo)
                        Text(badge.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.skyText)
                        Text(badge.description)
                            .font(.caption)
                            .foregroundColor(.skyMuted)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.07), radius: 8, y: 2)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

            Spacer()

            SKYPrimaryButton(title: "Back to Home") { dismiss() }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

            ShareLink(item: celebrationShareText) {
                Label("Share Your Practice", systemImage: "square.and.arrow.up")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.skyIndigo)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.skyIndigoLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: newAchievement?.id)
    }

    private var celebrationShareText: String {
        if let lvl = newLevel {
            return "Just reached Level \(lvl) on SKY Companion 🏆 \(celebrationStreak) days of consistent SKY Breath practice."
        }
        if celebrationStreak > 1 {
            return "Day \(celebrationStreak) of my SKY Breath journey 🔥 Consistent practice, consistent peace."
        }
        return "Just completed a SKY Breath Meditation session ✨ Feeling centered and clear."
    }

    private var celebrationSubline: String {
        if newLevel != nil       { return "You've reached a new level of practice." }
        if newAchievement != nil { return "A new achievement was unlocked!" }
        return celebrationStreak > 0 ? "Keep the momentum going." : "Every practice counts."
    }

    private func levelName(for level: Int) -> String {
        let names = ["", "Seeker", "Practitioner", "Steady Breather", "Inner Circle", "SKY Guide", "Luminous"]
        return names.indices.contains(level) ? names[level] : "Seeker"
    }

    private func handleMood(score: Int) async {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let prevLevel = store.localLevel
        let prevEarned = Set(store.achievements.filter { $0.earned }.map(\.id))

        await store.logSession(type: sessionType, durationSeconds: durationSeconds,
                               moodScore: score, note: trimmed.isEmpty ? nil : trimmed)

        celebrationStreak = store.localCurrentStreak
        let afterLevel = store.localLevel
        if afterLevel > prevLevel { newLevel = afterLevel }
        newAchievement = store.achievements.first { $0.earned && !prevEarned.contains($0.id) }
        showCelebration = true
    }

    private func handleSkip() async {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        await store.logSession(type: sessionType, durationSeconds: durationSeconds,
                               moodScore: nil, note: trimmed.isEmpty ? nil : trimmed)
        dismiss()
    }

    private func formatDuration(_ seconds: Int) -> String {
        "\(seconds / 60)m \(seconds % 60)s"
    }
}
