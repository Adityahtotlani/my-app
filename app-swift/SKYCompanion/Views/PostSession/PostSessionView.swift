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
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.skyText)

            // Summary card
            VStack(alignment: .leading, spacing: 12) {
                Text("SUMMARY")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.skySub).kerning(0.5)

                HStack {
                    VStack(spacing: 4) {
                        Text(formatDuration(durationSeconds))
                            .font(.system(size: 22, weight: .bold)).foregroundColor(.skyIndigo)
                        Text("Duration").font(.caption).foregroundColor(.skyMuted)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40)

                    VStack(spacing: 4) {
                        Text("+\(xpEarned) XP")
                            .font(.system(size: 22, weight: .bold)).foregroundColor(.skyIndigo)
                        Text("Earned").font(.caption).foregroundColor(.skyMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .skyCard()

            // Insight card
            VStack(alignment: .leading, spacing: 8) {
                Text("SCIENCE INSIGHT")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.skyIndigo).kerning(0.5)
                Text(insight)
                    .font(.system(size: 15))
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
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.skySub)
                TextField("How was your practice today? (optional)", text: $note, axis: .vertical)
                    .font(.system(size: 14))
                    .foregroundColor(.skyText)
                    .lineLimit(3...5)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    }
            }

            // Mood picker
            VStack(spacing: 16) {
                Text("How do you feel?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.skyText)

                HStack(spacing: 12) {
                    ForEach(moods, id: \.score) { mood in
                        Button {
                            Task { await handleMood(score: mood.score) }
                        } label: {
                            Text(mood.emoji).font(.system(size: 30))
                                .frame(width: 56, height: 56)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                        }
                    }
                }

                Button("Skip") {
                    Task { await handleSkip() }
                }
                .font(.system(size: 14))
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

            // Icon — trophy if leveled up, fire for streak, sparkle otherwise
            Text(newLevel != nil ? "🏆" : (celebrationStreak > 1 ? "🔥" : "✨"))
                .font(.system(size: 80))
                .padding(.bottom, 16)

            // Primary headline
            Group {
                if let lvl = newLevel {
                    VStack(spacing: 4) {
                        Text("Level Up!")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(.skyIndigo)
                        Text(levelName(for: lvl))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.skySub)
                    }
                } else {
                    Text(celebrationStreak > 0
                         ? "\(celebrationStreak) Day\(celebrationStreak == 1 ? "" : "s") Streak!"
                         : "Session Logged!")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.skyText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.bottom, 8)

            Text(celebrationSubline)
                .font(.system(size: 16))
                .foregroundColor(.skySub)
                .padding(.bottom, 24)

            // XP badge
            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("+\(xpEarned) XP Earned")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 67/255, green: 56/255, blue: 202/255))
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(Color.skyIndigoLight)
            .clipShape(Capsule())

            // Achievement unlock callout
            if let badge = newAchievement {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.skyIndigoLight).frame(width: 42, height: 42)
                        Image(systemName: badge.icon)
                            .foregroundColor(.skyIndigo).font(.system(size: 18))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACHIEVEMENT UNLOCKED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.skyIndigo)
                        Text(badge.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.skyText)
                        Text(badge.description)
                            .font(.system(size: 12))
                            .foregroundColor(.skyMuted)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.07), radius: 8, y: 2)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

            Spacer()

            SKYPrimaryButton(title: "Back to Home") { dismiss() }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: newAchievement?.id)
    }

    private var celebrationSubline: String {
        if newLevel != nil      { return "You've reached a new level of practice." }
        if newAchievement != nil { return "A new achievement was unlocked!" }
        return celebrationStreak > 0 ? "Keep the momentum going." : "Every practice counts."
    }

    private func levelName(for level: Int) -> String {
        let names = ["", "Seeker", "Practitioner", "Steady Breather", "Inner Circle", "SKY Guide", "Luminous"]
        return names.indices.contains(level) ? names[level] : "Seeker"
    }

    // MARK: - Helpers

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
