import SwiftUI

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

    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Header
                        Text("Community")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundColor(.skyText)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Daily quote
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Daily Reflection", systemImage: "quote.bubble.fill")
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(.skyIndigo)
                            Text("\"\(dailyQuote.text)\"")
                                .font(.system(size: 16))
                                .italic()
                                .foregroundColor(.skyText)
                                .lineSpacing(4)
                            Text("— \(dailyQuote.author)")
                                .font(.caption)
                                .foregroundColor(.skyMuted)
                        }
                        .skyCard()

                        // Your contribution
                        VStack(alignment: .leading, spacing: 12) {
                            Text("YOUR CONTRIBUTION")
                                .font(.caption).fontWeight(.bold)
                                .foregroundColor(.skySub).kerning(1)

                            Text("You're practicing alongside thousands of Art of Living alumni worldwide.")
                                .font(.system(size: 14))
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

                        // Satsang check-in
                        SatsangCheckInCard()

                        // Part 2 course
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

                        // Online programs
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
            Text(value).font(.system(size: 16, weight: .bold)).foregroundColor(.skyText)
            Text(label).font(.system(size: 10)).foregroundColor(.skySub)
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
                        .foregroundColor(.skyIndigo).font(.system(size: 16))
                }
                Text("Satsang Check-In")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.skyText)
            }

            Text("Attended a group session today? Check in to earn +75 XP and keep the community alive.")
                .font(.system(size: 14))
                .foregroundColor(.skySub)
                .lineSpacing(3)

            if store.checkedInSatsangToday {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
                    Text("Checked in today · +75 XP earned")
                        .font(.system(size: 14, weight: .semibold))
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
                            .font(.system(size: 14, weight: .semibold))
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
                    .font(.system(size: 13))
                    .foregroundColor(.skyIndigo)
            }
        }
        .padding(16)
        .background(Color.white)
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
                    Image(systemName: icon).foregroundColor(iconFg).font(.system(size: 16))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.skyText)
            }

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.skySub)
                .lineSpacing(3)

            if let badge = xpBadge {
                Text(badge)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 22/255, green: 163/255, blue: 74/255))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(red: 240/255, green: 253/255, blue: 244/255))
                    .clipShape(Capsule())
            }

            Link(destination: url) {
                Text(linkText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.skyIndigo)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
    }
}
