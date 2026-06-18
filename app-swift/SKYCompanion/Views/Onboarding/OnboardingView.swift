import SwiftUI

private let intentions = ["Reduce Stress", "Better Sleep", "More Energy", "Inner Peace", "Daily Discipline"]

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var step = 0
    @State private var name: String = ""
    @State private var selectedIntention: String?
    @State private var selectedReminderIdx: Int?
    @State private var welcomeAppeared = false

    var body: some View {
        ZStack {
            Color.skyBg.ignoresSafeArea()

            TabView(selection: $step) {
                welcomeStep.tag(0)
                nameStep.tag(1)
                intentionStep.tag(2)
                reminderStep.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: step)

            // Step progress dots
            VStack {
                HStack(spacing: 8) {
                    ForEach(0..<4) { i in
                        Capsule()
                            .fill(i == step ? Color.skyIndigo : Color(UIColor.systemGray4))
                            .frame(width: i == step ? 22 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: step)
                    }
                }
                .padding(.top, 56)
                Spacer()
            }
        }
    }

    // MARK: Step 0 — Welcome
    private var welcomeStep: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle().fill(Color.skyIndigoLight).frame(width: 132, height: 132)
                Circle().fill(Color.skyIndigo.opacity(0.18)).frame(width: 98, height: 98)
                Circle().fill(Color.skyIndigo).frame(width: 64, height: 64)
                Image(systemName: "wind").font(.title.weight(.medium)).foregroundColor(.white)
            }
            .scaleEffect(welcomeAppeared ? 1.0 : 0.55)
            .opacity(welcomeAppeared ? 1.0 : 0)
            .animation(.spring(response: 0.75, dampingFraction: 0.6).delay(0.1), value: welcomeAppeared)

            VStack(spacing: 8) {
                Text("Welcome to\nSKY Companion")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundColor(.skyText)
                    .multilineTextAlignment(.center)
                Text("Your daily breath practice, guided.")
                    .font(.subheadline)
                    .foregroundColor(.skySub)
            }
            .opacity(welcomeAppeared ? 1 : 0)
            .offset(y: welcomeAppeared ? 0 : 14)
            .animation(.easeOut(duration: 0.45).delay(0.3), value: welcomeAppeared)

            VStack(spacing: 12) {
                OnboardingBullet(icon: "wind",       text: "5-phase guided SKY sessions")
                OnboardingBullet(icon: "flame.fill", text: "Daily streak & XP to keep you going")
                OnboardingBullet(icon: "star.fill",  text: "Science-backed insights after every session")
            }
            .opacity(welcomeAppeared ? 1 : 0)
            .offset(y: welcomeAppeared ? 0 : 14)
            .animation(.easeOut(duration: 0.45).delay(0.45), value: welcomeAppeared)

            Spacer()
            SKYPrimaryButton(title: "Get Started") { step = 1 }
                .padding(.bottom, 40)
                .opacity(welcomeAppeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: welcomeAppeared)
        }
        .padding(.horizontal, 24)
        .onAppear { welcomeAppeared = true }
    }

    // MARK: Step 1 — Name
    private var nameStep: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 8) {
                Text("What should we\ncall you?")
                    .font(.title.weight(.bold))
                    .foregroundColor(.skyText)
                    .multilineTextAlignment(.center)
                Text("This is how you'll appear in your practice.")
                    .font(.subheadline)
                    .foregroundColor(.skySub)
                    .multilineTextAlignment(.center)
            }

            SKYTextField(placeholder: "Your first name", text: $name)

            Spacer()
            SKYPrimaryButton(title: "Continue", disabled: name.trimmingCharacters(in: .whitespaces).isEmpty) {
                step = 2
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }

    // MARK: Step 2 — Intention
    private var intentionStep: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Why are you here?")
                .font(.title.weight(.bold))
                .foregroundColor(.skyText)

            FlowLayout(items: intentions, selected: selectedIntention) { item in
                selectedIntention = item
            }

            Spacer()
            SKYPrimaryButton(title: "Continue", disabled: selectedIntention == nil) {
                step = 3
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }

    // MARK: Step 3 — Reminder
    private var reminderStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Choose your\npractice time")
                .font(.title.weight(.bold))
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
                let trimmedName = name.trimmingCharacters(in: .whitespaces)
                if !trimmedName.isEmpty { store.localName = trimmedName }
                let chosen = reminderOptions[idx]
                Task {
                    let granted = await NotificationService.requestPermission()
                    if granted {
                        await NotificationService.scheduleReminder(hour: chosen.hour, minute: chosen.minute)
                    }
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
                .font(.subheadline)
                .foregroundColor(.skyText)
            Spacer()
        }
        .padding(16)
        .background(Color.skyBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
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
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isSelected ? .white : Color(red: 71/255, green: 85/255, blue: 105/255))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 18)
                    .background(isSelected ? Color.skyIndigo : Color(UIColor.systemGray6))
                    .clipShape(Capsule())
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
                    .font(.callout.weight(.semibold))
                    .foregroundColor(isSelected ? .white : .skyText)
                Spacer()
            }
            .padding(18)
            .background(isSelected ? Color.skyIndigo : Color.skyBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.skyIndigo : Color.clear, lineWidth: 2)
            }
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
