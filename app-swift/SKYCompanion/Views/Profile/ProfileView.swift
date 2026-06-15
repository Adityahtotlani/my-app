import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showReminderSheet = false
    @State private var selectedReminderIdx: Int = 0
    @State private var showLogoutAlert = false
    @State private var showIntentionSheet = false
    @State private var showNameSheet = false
    @State private var showResetAlert = false
    @State private var showGoalSheet = false
    @State private var goalDraft = 5

    private var user: User? { store.user }
    private var reminderDisplay: String {
        ReminderOption(label: "", hour: store.reminderHour, minute: store.reminderMinute).displayTime
    }
    private var localLevelName: String {
        let names = ["", "Seeker", "Practitioner", "Steady Breather", "Inner Circle", "SKY Guide", "Luminous"]
        let lvl = user?.level ?? store.localLevel
        return names.indices.contains(lvl) ? names[lvl] : "Seeker"
    }
    private var currentStreak: Int { user?.currentStreak ?? store.localCurrentStreak }
    private var maxStreak: Int     { user?.maxStreak     ?? store.localMaxStreak }
    private var totalXP: Int       { user?.totalXP       ?? store.localTotalXP }
    private var level: Int         { user?.level         ?? store.localLevel }

    private func formatMinutes(_ total: Int) -> String {
        if total < 60 { return "\(total)m" }
        return "\(total / 60)h \(total % 60)m"
    }

    var body: some View {
        NavigationStack {
            List {
                // Avatar header
                Section {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().fill(Color.skyIndigoLight).frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .foregroundColor(.skyIndigo).font(.system(size: 36))
                        }
                        Text(user?.email ?? (store.localName.isEmpty ? "Practitioner" : store.localName))
                            .font(.title3.weight(.bold))
                            .foregroundColor(.skyText)

                        HStack(spacing: 8) {
                            BadgeView(text: localLevelName, bg: Color.skyIndigoLight, fg: .skyIndigo)
                            BadgeView(text: "Verified Practitioner",
                                      bg: Color(red: 220/255, green: 252/255, blue: 231/255),
                                      fg: Color(red: 22/255, green: 101/255, blue: 52/255))
                        }
                        if let intention = store.intention, !intention.isEmpty {
                            Label("Practicing for: \(intention)", systemImage: "leaf.fill")
                                .font(.caption)
                                .foregroundColor(.skySub)
                                .padding(.top, 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

                // Stats row
                Section {
                    HStack(spacing: 12) {
                        MiniStatPill(icon: "flame.fill",           iconColor: .red,       value: "\(currentStreak)",            label: "Streak")
                        MiniStatPill(icon: "checkmark.circle.fill", iconColor: .skyIndigo, value: "\(store.localSessions.count)", label: "Sessions")
                        MiniStatPill(icon: "star.fill",             iconColor: .yellow,    value: "\(totalXP)",                  label: "Total XP")
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)

                // Achievements
                Section {
                    AchievementsSection(achievements: store.achievements)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)

                // Account settings — tappable rows
                Section("Account Settings") {
                    settingRow(icon: "person.fill", label: "Display Name",
                               value: store.localName.isEmpty ? "Practitioner" : store.localName) {
                        showNameSheet = true
                    }
                    settingRow(icon: "leaf.fill", label: "Practice Intention",
                               value: store.intention ?? "Not set",
                               valueColor: store.intention != nil ? .skyIndigo : .secondary) {
                        showIntentionSheet = true
                    }
                    settingRow(icon: "gearshape.fill", label: "Practice Reminder",
                               value: reminderDisplay, valueColor: .skyIndigo) {
                        selectedReminderIdx = reminderOptions.firstIndex(where: {
                            $0.hour == store.reminderHour && $0.minute == store.reminderMinute
                        }) ?? 0
                        showReminderSheet = true
                    }
                    settingRow(icon: "target", label: "Weekly Goal",
                               value: "\(store.weeklyGoal) days/week", valueColor: .skyIndigo) {
                        goalDraft = store.weeklyGoal
                        showGoalSheet = true
                    }
                    infoRow(icon: "bell.fill",       label: "Notifications", value: "Enabled")
                    infoRow(icon: "lock.shield.fill", label: "Privacy",       value: "Managed")
                }

                // Apple Health sync
                Section("Apple Health") {
                    if HealthKitService.shared.isAvailable {
                        Toggle(isOn: Binding(
                            get: { store.healthKitEnabled },
                            set: { newValue in
                                if newValue {
                                    Task {
                                        let granted = await HealthKitService.shared.requestAuthorization()
                                        store.healthKitEnabled = granted
                                    }
                                } else {
                                    store.healthKitEnabled = false
                                }
                            }
                        )) {
                            Label("Sync Mindful Minutes", systemImage: "heart.fill")
                                .foregroundStyle(.primary)
                        }
                        .tint(.skyIndigo)
                        if store.healthKitEnabled {
                            infoRow(icon: "checkmark.shield.fill", label: "Status", value: "Active")
                        }
                    } else {
                        infoRow(icon: "heart.slash.fill", label: "Apple Health", value: "Not Available")
                    }
                }

                // Practice stats — read-only
                Section("Your Practice") {
                    infoRow(icon: "flame.fill",  label: "Personal Best Streak",  value: "\(maxStreak) days")
                    infoRow(icon: "star.fill",   label: "Level",                  value: "\(localLevelName) (Lvl \(level))")
                    infoRow(icon: "clock.fill",  label: "Total Practice Time",    value: formatMinutes(store.localTotalMinutes))
                }

                // Danger zone
                Section {
                    Button("Reset All Practice Data", role: .destructive) { showResetAlert = true }
                    Button(role: .destructive) { showLogoutAlert = true } label: {
                        Label("Log Out", systemImage: "arrow.right.square.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.skyBg.ignoresSafeArea())
            .tint(.skyIndigo)
            .toolbar(.hidden, for: .navigationBar)
            .alert("Reset All Practice Data?", isPresented: $showResetAlert) {
                Button("Reset Everything", role: .destructive) { store.resetAllLocalData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes all sessions, streak, and XP. Your account settings are kept.")
            }
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) { store.logout() }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .sheet(isPresented: $showNameSheet) {
                NameEditSheet(current: store.localName) { store.localName = $0 }
                    .presentationDetents([.height(260)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showIntentionSheet) {
                IntentionPickerSheet(current: store.intention) { store.setIntention($0) }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showReminderSheet) {
                ReminderSheet(selectedIdx: $selectedReminderIdx) { idx in
                    let chosen = reminderOptions[idx]
                    Task {
                        await NotificationService.scheduleReminder(hour: chosen.hour, minute: chosen.minute)
                        store.setReminder(hour: chosen.hour, minute: chosen.minute)
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showGoalSheet) {
                WeeklyGoalSheet(goal: $goalDraft) { store.weeklyGoal = $0 }
                    .presentationDetents([.height(340)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Row builders

    @ViewBuilder
    private func settingRow(icon: String, label: String, value: String,
                            valueColor: Color = .secondary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(label, systemImage: icon)
                    .foregroundStyle(.primary)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(valueColor)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .tint(.primary)
    }

    @ViewBuilder
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Sub-components

private struct BadgeView: View {
    let text: String
    let bg: Color
    let fg: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(fg)
            .padding(.horizontal, 12).padding(.vertical, 4)
            .background(bg, in: Capsule())
    }
}

private struct MiniStatPill: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(iconColor).font(.title3)
            Text(value).font(.title2.weight(.bold)).foregroundColor(.skyText)
            Text(label).font(.caption2).foregroundColor(.skySub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}

private struct AchievementsSection: View {
    let achievements: [Achievement]
    private var earnedCount: Int { achievements.filter { $0.earned }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ACHIEVEMENTS")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.skySub)
                    .kerning(1)
                Spacer()
                Text("\(earnedCount) of \(achievements.count)")
                    .font(.caption)
                    .foregroundColor(.skyMuted)
            }
            .padding(.top, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(achievements) { AchievementCard(badge: $0) }
            }
        }
    }
}

private struct AchievementCard: View {
    let badge: Achievement

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badge.earned ? Color.skyIndigoLight : Color(UIColor.systemGray6))
                    .frame(width: 52, height: 52)
                Image(systemName: badge.icon)
                    .font(.system(size: 22))
                    .foregroundColor(badge.earned ? .skyIndigo : Color(UIColor.systemGray3))
            }
            Text(badge.title)
                .font(.caption.weight(.semibold))
                .foregroundColor(badge.earned ? .skyText : .skyMuted)
                .multilineTextAlignment(.center)
            Text(badge.description)
                .font(.caption2)
                .foregroundColor(.skyMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(badge.earned ? 0.06 : 0.02), radius: 8, y: 2)
        .opacity(badge.earned ? 1.0 : 0.5)
    }
}

private struct ReminderSheet: View {
    @Binding var selectedIdx: Int
    @Environment(\.dismiss) var dismiss
    let onSave: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Change Reminder")
                .font(.title3.weight(.bold))
                .foregroundColor(.skyText)
                .padding(.top, 4)

            ForEach(Array(reminderOptions.enumerated()), id: \.offset) { idx, option in
                let isSelected = selectedIdx == idx
                Button { selectedIdx = idx } label: {
                    HStack(spacing: 16) {
                        Image(systemName: iconName(for: option.hour))
                            .foregroundColor(isSelected ? .white : .skyIndigo)
                            .font(.title2)
                        Text(option.label)
                            .font(.callout.weight(.semibold))
                            .foregroundColor(isSelected ? .white : .skyText)
                        Spacer()
                    }
                    .padding(18)
                    .background(isSelected ? Color.skyIndigo : Color.skyBg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            SKYPrimaryButton(title: "Save") { onSave(selectedIdx); dismiss() }

            Button("Cancel") { dismiss() }
                .font(.subheadline)
                .foregroundColor(.skyMuted)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
    }

    private func iconName(for hour: Int) -> String {
        switch hour {
        case 0..<12: return "sunrise.fill"
        case 12:     return "sun.max.fill"
        default:     return "moon.fill"
        }
    }
}

private struct WeeklyGoalSheet: View {
    @Binding var goal: Int
    @Environment(\.dismiss) var dismiss
    let onSave: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Weekly Practice Goal")
                .font(.title3.weight(.bold))
                .foregroundColor(.skyText)
                .padding(.top, 4)

            Text("How many days per week do you want to practice SKY?")
                .font(.subheadline)
                .foregroundColor(.skySub)
                .lineSpacing(3)

            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Text("\(goal)")
                        .font(.system(size: 64, weight: .bold).monospacedDigit())
                        .foregroundColor(.skyIndigo)
                    Text("day\(goal == 1 ? "" : "s") per week")
                        .font(.subheadline)
                        .foregroundColor(.skySub)
                    Stepper("", value: $goal, in: 1...7)
                        .labelsHidden()
                        .tint(.skyIndigo)
                }
                Spacer()
            }
            .padding(20)
            .background(Color.skyIndigoLight)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()

            SKYPrimaryButton(title: "Save") { onSave(goal); dismiss() }
            Button("Cancel") { dismiss() }
                .font(.subheadline).foregroundColor(.skyMuted).frame(maxWidth: .infinity)
        }
        .padding(24)
    }
}

private struct NameEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    let onSave: (String) -> Void

    init(current: String, onSave: @escaping (String) -> Void) {
        _name = State(initialValue: current)
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Display Name")
                .font(.title3.weight(.bold))
                .foregroundColor(.skyText)
                .padding(.top, 4)

            SKYTextField(placeholder: "Your first name", text: $name)
            Spacer()

            SKYPrimaryButton(title: "Save", disabled: name.trimmingCharacters(in: .whitespaces).isEmpty) {
                let trimmed = name.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { onSave(trimmed) }
                dismiss()
            }
            Button("Cancel") { dismiss() }
                .font(.subheadline).foregroundColor(.skyMuted).frame(maxWidth: .infinity)
        }
        .padding(24)
    }
}

private struct IntentionPickerSheet: View {
    let current: String?
    let onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var selected: String?

    private let options = ["Reduce Stress", "Better Sleep", "More Energy", "Inner Peace", "Daily Discipline"]

    init(current: String?, onSave: @escaping (String) -> Void) {
        self.current = current
        self.onSave = onSave
        _selected = State(initialValue: current)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Update Intention")
                .font(.title3.weight(.bold))
                .foregroundColor(.skyText)
                .padding(.top, 4)
            Text("Why are you practicing SKY?")
                .font(.subheadline)
                .foregroundColor(.skySub)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 10) {
                ForEach(options, id: \.self) { item in
                    let isSelected = selected == item
                    Button(item) { selected = item }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(isSelected ? .white : Color(red: 71/255, green: 85/255, blue: 105/255))
                        .padding(.vertical, 12).padding(.horizontal, 18)
                        .background(isSelected ? Color.skyIndigo : Color(UIColor.systemGray6))
                        .clipShape(Capsule())
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }

            Spacer()

            SKYPrimaryButton(title: "Save", disabled: selected == nil) {
                if let s = selected { onSave(s) }
                dismiss()
            }
            Button("Cancel") { dismiss() }
                .font(.subheadline).foregroundColor(.skyMuted).frame(maxWidth: .infinity)
        }
        .padding(24)
    }
}
