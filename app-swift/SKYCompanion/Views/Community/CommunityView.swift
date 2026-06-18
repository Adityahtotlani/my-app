import SwiftUI

private struct BreathStep {
    let label: String
    let duration: Double
    let targetScale: CGFloat  // 1.0 = full inhale, 0.5 = exhale/small
}

private struct BreathExercise: Identifiable {
    let id: String
    let name: String
    let tagline: String
    let icon: String
    let color: Color
    let pattern: [BreathStep]
    let totalReps: Int
}

private let breathExercises: [BreathExercise] = [
    BreathExercise(
        id: "coherent",
        name: "Coherent Breathing",
        tagline: "~6 breaths/min · maximises HRV",
        icon: "waveform",
        color: Color(red: 16/255, green: 185/255, blue: 129/255),
        pattern: [
            BreathStep(label: "Inhale", duration: 5, targetScale: 1.0),
            BreathStep(label: "Exhale", duration: 5, targetScale: 0.5),
        ],
        totalReps: 6
    ),
    BreathExercise(
        id: "box",
        name: "Box Breathing",
        tagline: "Equal 4s sides · calms the mind",
        icon: "square",
        color: Color.skyIndigo,
        pattern: [
            BreathStep(label: "Inhale",       duration: 4, targetScale: 1.0),
            BreathStep(label: "Hold",         duration: 4, targetScale: 1.0),
            BreathStep(label: "Exhale",       duration: 4, targetScale: 0.5),
            BreathStep(label: "Hold",         duration: 4, targetScale: 0.5),
        ],
        totalReps: 5
    ),
    BreathExercise(
        id: "478",
        name: "4-7-8 Breathing",
        tagline: "Deep relaxation · aids sleep",
        icon: "moon.fill",
        color: Color(red: 139/255, green: 92/255, blue: 246/255),
        pattern: [
            BreathStep(label: "Inhale", duration: 4,  targetScale: 1.0),
            BreathStep(label: "Hold",   duration: 7,  targetScale: 1.0),
            BreathStep(label: "Exhale", duration: 8,  targetScale: 0.5),
        ],
        totalReps: 4
    ),
]

private let breathingTips: [String] = [
    "Practice on an empty stomach — wait 2–3 hours after a meal for best results.",
    "After your session, sit in silence for at least 10 minutes. Integration is half the practice.",
    "In the fast cycle, let the breath lead rather than forcing it. Surrender is the technique.",
    "A slight inner smile during practice relaxes the jaw, face, and ultimately the mind.",
    "Consistency beats perfection. A 15-minute short session on a busy day is far better than skipping.",
    "The medium cycle at ~6 breaths/min is the most researched — it synchronises heart and brain rhythm.",
    "Keep your spine erect and eyes gently closed throughout the session for the deepest effect.",
    "If the mind wanders in the rest phase, return attention softly to the sound of your breath.",
]

private let quotes: [(text: String, author: String)] = [
    ("The breath is the bridge between the body and the mind.", "Sri Sri Ravi Shankar"),
    ("When the breath wanders, the mind is unsteady. When the breath is still, so is the mind.", "Hatha Yoga Pradipika"),
    ("Breathing in, I calm my body. Breathing out, I smile.", "Thich Nhat Hanh"),
    ("SKY is not just a technique, it is a way of being.", "Bhanu Narasimhan"),
    ("Each breath is a new beginning.", "Art of Living Foundation"),
    ("The rhythm of the breath is the music of the soul.", "Dinesh K., AoL Faculty"),
    ("A few minutes of deep breathing can dissolve hours of tension.", "Sri Sri Ravi Shankar"),
    ("Your breath is always with you. So is peace.", "Art of Living Foundation"),
]

struct CommunityView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedExercise: BreathExercise?

    private var dailyQuote: (text: String, author: String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[dayOfYear % quotes.count]
    }

    private var dailyTip: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return breathingTips[(dayOfYear + 3) % breathingTips.count]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        Text("Community")
                            .font(.largeTitle.weight(.heavy))
                            .foregroundColor(.skyText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Daily quote
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Daily Reflection", systemImage: "quote.bubble.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.skyIndigo)
                            Text("\"\(dailyQuote.text)\"")
                                .font(.callout)
                                .italic()
                                .foregroundColor(.skyText)
                                .lineSpacing(4)
                            Text("— \(dailyQuote.author)")
                                .font(.caption)
                                .foregroundColor(.skyMuted)
                        }
                        .skyCard()

                        // Global community
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Global Community", systemImage: "globe")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.skyIndigo)
                            Text("You're practicing alongside Art of Living alumni worldwide who do SKY every day.")
                                .font(.footnote)
                                .foregroundColor(.skySub)
                                .lineSpacing(3)
                            HStack(spacing: 0) {
                                ForEach([("200K+", "Alumni"), ("156", "Countries"), ("40+", "Years")], id: \.0) { val, label in
                                    VStack(spacing: 3) {
                                        Text(val)
                                            .font(.headline)
                                            .foregroundColor(.skyIndigo)
                                        Text(label)
                                            .font(.caption2)
                                            .foregroundColor(.skyMuted)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .skyCard()

                        // Your contribution
                        VStack(alignment: .leading, spacing: 12) {
                            Text("YOUR CONTRIBUTION")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.skySub).kerning(1)

                            Text("You're practicing alongside thousands of Art of Living alumni worldwide.")
                                .font(.footnote)
                                .foregroundColor(.skySub)
                                .lineSpacing(3)

                            HStack(spacing: 12) {
                                CommunityStatPill(
                                    icon: "checkmark.circle.fill", iconColor: .skyIndigo,
                                    value: "\(store.localSessions.count)", label: "Sessions")
                                CommunityStatPill(
                                    icon: "flame.fill", iconColor: .red,
                                    value: "\(store.localCurrentStreak)", label: "Day Streak")
                                CommunityStatPill(
                                    icon: "star.fill", iconColor: .yellow,
                                    value: "\(store.localTotalXP)", label: "Total XP")
                            }
                        }
                        .skyCard()

                        // Daily practice tip
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Practitioner Tip", systemImage: "lightbulb.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Color(red: 161/255, green: 98/255, blue: 7/255))
                            Text(dailyTip)
                                .font(.footnote)
                                .foregroundColor(.skyText)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(Color(red: 254/255, green: 249/255, blue: 195/255).opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 253/255, green: 230/255, blue: 138/255), lineWidth: 1)
                        }

                        SatsangCheckInCard()

                        // Breathing library
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Breathing Library", systemImage: "lungs.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.skyIndigo)
                            Text("Quick guided exercises for anytime — no full session required.")
                                .font(.footnote)
                                .foregroundColor(.skySub)
                                .lineSpacing(3)
                            ForEach(breathExercises) { exercise in
                                Button { selectedExercise = exercise } label: {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(exercise.color.opacity(0.15))
                                                .frame(width: 42, height: 42)
                                            Image(systemName: exercise.icon)
                                                .font(.callout)
                                                .foregroundColor(exercise.color)
                                        }
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(exercise.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(.skyText)
                                            Text(exercise.tagline)
                                                .font(.caption)
                                                .foregroundColor(.skySub)
                                        }
                                        Spacer()
                                        Image(systemName: "play.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(exercise.color.opacity(0.8))
                                    }
                                    .padding(14)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
                        .sheet(item: $selectedExercise) { exercise in
                            QuickBreathSheet(exercise: exercise)
                                .presentationDragIndicator(.visible)
                        }

                        CommunityLinkCard(
                            icon: "sparkles",
                            iconBg: Color(red: 254/255, green: 249/255, blue: 195/255),
                            iconFg: Color(red: 161/255, green: 98/255, blue: 7/255),
                            title: "Advance Meditation Course",
                            subtitle: "Deepen your practice with guided silence, advanced breathing, and Yoga Nidra.",
                            xpBadge: nil,
                            linkText: "Browse Courses",
                            url: URL(string: "https://www.artofliving.org/us-en/advance-meditation-course")!
                        )

                        CommunityLinkCard(
                            icon: "video.fill",
                            iconBg: Color(red: 240/255, green: 253/255, blue: 244/255),
                            iconFg: Color(red: 22/255, green: 163/255, blue: 74/255),
                            title: "Online Programs",
                            subtitle: "Can't travel? Live-streamed and on-demand programs bring the retreat to you.",
                            xpBadge: nil,
                            linkText: "Explore Online",
                            url: URL(string: "https://www.artofliving.org/us-en/online-programs")!
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct CommunityStatPill: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundColor(iconColor).font(.callout)
            Text(value).font(.callout.weight(.bold)).foregroundColor(.skyText)
            Text(label).font(.caption2).foregroundColor(.skySub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.skyBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SatsangCheckInCard: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 224/255, green: 231/255, blue: 255/255))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.skyIndigo).font(.callout)
                }
                Text("Satsang Check-In")
                    .font(.callout.weight(.bold))
                    .foregroundColor(.skyText)
            }

            Text("Attended a group session today? Check in to earn +75 XP and keep the community alive.")
                .font(.footnote)
                .foregroundColor(.skySub)
                .lineSpacing(3)

            if store.checkedInSatsangToday {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
                    Text("Checked in today · +75 XP earned")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 240/255, green: 253/255, blue: 244/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Button {
                    store.logSatsangCheckIn()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Check In  ·  +75 XP")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.skyIndigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Link(destination: URL(string: "https://www.artofliving.org/us-en/satsang")!) {
                Text("Find a Satsang near you →")
                    .font(.footnote)
                    .foregroundColor(.skyIndigo)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}

private struct CommunityLinkCard: View {
    let icon: String
    let iconBg: Color
    let iconFg: Color
    let title: String
    let subtitle: String
    let xpBadge: String?
    let linkText: String
    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(iconBg).frame(width: 40, height: 40)
                    Image(systemName: icon).foregroundColor(iconFg).font(.callout)
                }
                Text(title)
                    .font(.callout.weight(.bold))
                    .foregroundColor(.skyText)
            }

            Text(subtitle)
                .font(.footnote)
                .foregroundColor(.skySub)
                .lineSpacing(3)

            if let badge = xpBadge {
                Text(badge)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(red: 240/255, green: 253/255, blue: 244/255))
                    .clipShape(Capsule())
            }

            Link(destination: url) {
                Text(linkText)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.skyIndigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}

private struct QuickBreathSheet: View {
    let exercise: BreathExercise
    @Environment(\.dismiss) var dismiss

    @State private var scale: CGFloat = 0.5
    @State private var stepLabel = "Get ready…"
    @State private var currentRep = 0
    @State private var isComplete = false
    @State private var breathTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.skyBg.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 6) {
                    Text(exercise.name)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.skyText)
                    Text(exercise.tagline)
                        .font(.subheadline)
                        .foregroundColor(.skySub)
                }

                ZStack {
                    Circle()
                        .fill(exercise.color.opacity(0.08))
                        .frame(width: 220, height: 220)
                    Circle()
                        .fill(exercise.color.opacity(0.2))
                        .frame(width: 220 * scale, height: 220 * scale)
                    Circle()
                        .fill(exercise.color)
                        .frame(width: 76, height: 76)
                    Text(stepLabel)
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }

                if isComplete {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(exercise.color)
                        Text("Complete")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.skyText)
                        Text("Notice how you feel right now.")
                            .font(.subheadline)
                            .foregroundColor(.skySub)
                    }
                } else {
                    Text("Round \(currentRep + 1) of \(exercise.totalReps)")
                        .font(.subheadline)
                        .foregroundColor(.skySub)
                }

                Spacer()

                if isComplete {
                    SKYPrimaryButton(title: "Done") { dismiss() }
                        .padding(.horizontal, 32)
                } else {
                    Button("Stop") { dismiss() }
                        .font(.footnote)
                        .foregroundColor(.skyMuted)
                }

                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            breathTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(600))
                for rep in 0..<exercise.totalReps {
                    guard !Task.isCancelled else { return }
                    currentRep = rep
                    for step in exercise.pattern {
                        guard !Task.isCancelled else { return }
                        stepLabel = step.label
                        withAnimation(.easeInOut(duration: step.duration)) {
                            scale = step.targetScale
                        }
                        try? await Task.sleep(for: .seconds(step.duration))
                    }
                }
                guard !Task.isCancelled else { return }
                isComplete = true
                stepLabel = ""
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        .onDisappear { breathTask?.cancel() }
    }
}
