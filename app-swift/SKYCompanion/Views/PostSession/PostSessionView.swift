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

    var body: some View {
        ZStack {
            Color.skyBg.ignoresSafeArea()

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
                .skyCard()
                .background(Color.skyIndigoLight)
                .cornerRadius(16)

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
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }

    private func handleMood(score: Int) async {
        await store.logSession(type: sessionType, durationSeconds: durationSeconds, moodScore: score)
        dismiss()
    }

    private func formatDuration(_ seconds: Int) -> String {
        "\(seconds / 60)m \(seconds % 60)s"
    }
}
