import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showReminderSheet = false
    @State private var selectedReminderIdx: Int = 0
    @State private var showLogoutAlert = false

    private var user: User? { store.user }
    private var reminderDisplay: String {
        ReminderOption(label: "", hour: store.reminderHour, minute: store.reminderMinute).displayTime
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().fill(Color.skyIndigoLight).frame(width: 80, height: 80)
                                Image(systemName: "person.fill")
                                    .foregroundColor(.skyIndigo).font(.system(size: 36))
                            }
                            Text(user?.email ?? "")
                                .font(.system(size: 20, weight: .bold)).foregroundColor(.skyText)

                            HStack(spacing: 8) {
                                BadgeView(text: user?.levelName ?? "Seeker", bg: Color.skyIndigoLight, fg: .skyIndigo)
                                BadgeView(text: "Verified Practitioner",
                                          bg: Color(red: 220/255, green: 252/255, blue: 231/255),
                                          fg: Color(red: 22/255, green: 101/255, blue: 52/255))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(Color.white)

                        // Settings list
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ACCOUNT SETTINGS")
                                .font(.caption).fontWeight(.bold)
                                .foregroundColor(.skySub).kerning(1)
                                .padding(.top, 20)

                            ProfileRow(icon: "gearshape.fill", label: "Practice Reminder",
                                       value: reminderDisplay, valueColor: .skyIndigo) {
                                selectedReminderIdx = reminderOptions.firstIndex(where: {
                                    $0.hour == store.reminderHour && $0.minute == store.reminderMinute
                                }) ?? 0
                                showReminderSheet = true
                            }

                            ProfileRow(icon: "bell.fill", label: "Notifications", value: "Enabled")
                            ProfileRow(icon: "lock.shield.fill", label: "Privacy", value: "Managed")
                            ProfileRow(icon: "flame.fill", label: "Personal Best Streak",
                                       value: "\(user?.maxStreak ?? 0) days")
                            ProfileRow(icon: "star.fill", label: "Level",
                                       value: "\(user?.levelName ?? "Seeker") (Lvl \(user?.level ?? 1))")
                        }
                        .padding(.horizontal, 20)

                        // Logout
                        Button {
                            showLogoutAlert = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.right.square.fill")
                                Text("Log Out")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))
                            .frame(maxWidth: .infinity).padding(15)
                            .background(Color(red: 254/255, green: 226/255, blue: 226/255))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) { store.logout() }
            } message: {
                Text("Are you sure you want to log out?")
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
            }
        }
    }
}

private struct ProfileRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .skyMuted
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Image(systemName: icon).foregroundColor(.skySub).frame(width: 20)
                Text(label).font(.system(size: 16)).foregroundColor(.skyText)
                Spacer()
                Text(value).font(.system(size: 16)).foregroundColor(valueColor)
                if action != nil {
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.skyMuted)
                }
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(12)
        }
        .disabled(action == nil)
    }
}

private struct BadgeView: View {
    let text: String
    let bg: Color
    let fg: Color

    var body: some View {
        Text(text).font(.system(size: 12, weight: .semibold))
            .foregroundColor(fg)
            .padding(.horizontal, 12).padding(.vertical, 4)
            .background(bg).cornerRadius(20)
    }
}

private struct ReminderSheet: View {
    @Binding var selectedIdx: Int
    @Environment(\.dismiss) var dismiss
    let onSave: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Change Reminder")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.skyText)
                .padding(.top, 4)

            ForEach(Array(reminderOptions.enumerated()), id: \.offset) { idx, option in
                let isSelected = selectedIdx == idx
                Button { selectedIdx = idx } label: {
                    HStack(spacing: 16) {
                        Image(systemName: iconName(for: option.hour))
                            .foregroundColor(isSelected ? .white : .skyIndigo).font(.title2)
                        Text(option.label)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isSelected ? .white : .skyText)
                        Spacer()
                    }
                    .padding(18)
                    .background(isSelected ? Color.skyIndigo : Color.skyBg)
                    .cornerRadius(14)
                }
            }

            SKYPrimaryButton(title: "Save") {
                onSave(selectedIdx)
                dismiss()
            }

            Button("Cancel") { dismiss() }
                .font(.system(size: 15)).foregroundColor(.skyMuted).frame(maxWidth: .infinity)
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
