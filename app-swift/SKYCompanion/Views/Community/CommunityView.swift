import SwiftUI

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
