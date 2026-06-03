import SwiftUI

private let intentions = ["Reduce Stress", "Better Sleep", "More Energy", "Inner Peace", "Daily Discipline"]

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var step = 0
    @State private var selectedIntention: String?
    @State private var selectedReminderIdx: Int?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            TabView(selection: $step) {
                welcomeStep.tag(0)
                intentionStep.tag(1)
                reminderStep.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: step)
        }
    }

    // MARK: Step 0 — Welcome
    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Welcome to\nSKY Companion")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.skyText)
                .multilineTextAlignment(.center)
            Text("Your daily breath practice, guided.")
                .foregroundColor(.skySub)

            VStack(spacing: 12) {
                OnboardingBullet(icon: "wind", text: "5-phase guided SKY sessions")
                OnboardingBullet(icon: "flame.fill", text: "Daily streak & XP to keep you going")
                OnboardingBullet(icon: "star.fill", text: "Science-backed insights after every session")
            }
            Spacer()
            SKYPrimaryButton(title: "Get Started") { step = 1 }
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }

    // MARK: Step 1 — Intention
    private var intentionStep: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Why are you here?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.skyText)

            FlowLayout(items: intentions, selected: selectedIntention) { item in
                selectedIntention = item
            }

            Spacer()
            SKYPrimaryButton(title: "Continue", disabled: selectedIntention == nil) {
                step = 2
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }

    // MARK: Step 2 — Reminder
    private var reminderStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Choose your\npractice time")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.skyText)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(Array(reminderOptions.enumerated()), id: \.offset) { idx, option in
                    ReminderCard(option: option, isSelected: selectedReminderIdx == idx) {
                        selectedReminderIdx = idx
                    }
                }
            }

            Spacer()
            SKYPrimaryButton(title: "Begin Practice", disabled: selectedReminderIdx == nil) {
                guard let idx = selectedReminderIdx,
                      let intention = selectedIntention else { return }
                let chosen = reminderOptions[idx]
                Task {
                    await NotificationService.requestPermission()
                    await NotificationService.scheduleReminder(hour: chosen.hour, minute: chosen.minute)
                    store.completeOnboarding(intention: intention, hour: chosen.hour, minute: chosen.minute)
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Sub-components

private struct OnboardingBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.skyIndigo)
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.skyText)
            Spacer()
        }
        .padding(16)
        .background(Color.skyBg)
        .cornerRadius(14)
    }
}

private struct FlowLayout: View {
    let items: [String]
    let selected: String?
    let onSelect: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 10) {
            ForEach(items, id: \.self) { item in
                let isSelected = selected == item
                Button(item) { onSelect(item) }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(red: 71/255, green: 85/255, blue: 105/255))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 18)
                    .background(isSelected ? Color.skyIndigo : Color(UIColor.systemGray6))
                    .cornerRadius(24)
            }
        }
    }
}

private struct ReminderCard: View {
    let option: ReminderOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .foregroundColor(isSelected ? .white : .skyIndigo)
                    .font(.title2)
                Text(option.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .skyText)
                Spacer()
            }
            .padding(18)
            .background(isSelected ? Color.skyIndigo : Color.skyBg)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.skyIndigo : Color.clear, lineWidth: 2)
            )
        }
    }

    private var iconName: String {
        switch option.hour {
        case 0..<12: return "sunrise.fill"
        case 12:     return "sun.max.fill"
        default:     return "moon.fill"
        }
    }
}
