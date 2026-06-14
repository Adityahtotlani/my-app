import SwiftUI
import UIKit

private struct Phase {
    let id: String
    let name: String
    let duration: Int
    let breathRate: Double
    let isResting: Bool
}

private let fullPhases: [Phase] = [
    Phase(id: "warmup", name: "Warming Breaths",    duration: 300, breathRate: 4,  isResting: false),
    Phase(id: "slow",   name: "SKY - Slow Cycle",   duration: 480, breathRate: 10, isResting: false),
    Phase(id: "medium", name: "SKY - Medium Cycle", duration: 480, breathRate: 6,  isResting: false),
    Phase(id: "fast",   name: "SKY - Fast Cycle",   duration: 300, breathRate: 2,  isResting: false),
    Phase(id: "rest",   name: "Rest & Integration", duration: 300, breathRate: 0,  isResting: true),
]

private let shortPhases: [Phase] = [
    Phase(id: "warmup", name: "Warming Breaths",    duration: 180, breathRate: 4,  isResting: false),
    Phase(id: "slow",   name: "SKY - Slow Cycle",   duration: 240, breathRate: 10, isResting: false),
    Phase(id: "medium", name: "SKY - Medium Cycle", duration: 240, breathRate: 6,  isResting: false),
    Phase(id: "fast",   name: "SKY - Fast Cycle",   duration: 120, breathRate: 2,  isResting: false),
    Phase(id: "rest",   name: "Rest & Integration", duration: 120, breathRate: 0,  isResting: true),
]

struct PracticeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var sessionType: SessionType = .full
    @State private var isActive = false
    @State private var hasStarted = false
    @State private var currentPhaseIndex = 0
    @State private var timeLeft = 0
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @State private var navigateToPostSession = false
    @State private var showEndConfirm = false
    @State private var toastMessage: String = ""
    @State private var showPhaseToast = false
    @State private var toastTask: Task<Void, Never>?

    enum SessionType { case full, short }

    private var phases: [Phase] { sessionType == .full ? fullPhases : shortPhases }
    private var currentPhase: Phase { phases[currentPhaseIndex] }
    private var sessionNotStarted: Bool { !hasStarted }

    private var isCountingDown: Bool { hasStarted && isActive && timeLeft <= 10 && timeLeft > 0 }

    private var phaseGuidance: String? {
        guard hasStarted else { return nil }
        switch currentPhase.id {
        case "warmup": return "Breathe naturally · eyes closed"
        case "slow":   return "Lips sealed · through the nose"
        case "medium": return "Follow the rhythm · surrender"
        case "fast":   return "Let the breath breathe you"
        case "rest":   return "Lie down if possible · stay still"
        default:       return nil
        }
    }

    private var phaseProgress: Double {
        let phaseFraction = timeLeft > 0
            ? 1.0 - Double(timeLeft) / Double(currentPhase.duration)
            : 1.0
        return (Double(currentPhaseIndex) + phaseFraction) / Double(phases.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.skyBg.ignoresSafeArea()

                // Phase transition toast
                VStack {
                    if showPhaseToast {
                        Text(toastMessage)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(Color.skyIndigo.opacity(0.9))
                            .clipShape(Capsule())
                            .shadow(color: Color.skyIndigo.opacity(0.3), radius: 8, y: 4)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Spacer()
                }
                .padding(.top, 56)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showPhaseToast)
                .zIndex(1)

                VStack(spacing: 0) {

                    // Phase name + timer — animated on phase change via .id
                    VStack(spacing: 6) {
                        Text(currentPhase.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.skyText)
                        if let guidance = phaseGuidance {
                            Text(guidance)
                                .font(.system(size: 13))
                                .foregroundColor(.skyMuted)
                                .transition(.opacity)
                        }
                        Text(formatTime(timeLeft))
                            .font(.system(size: 52, weight: .light))
                            .foregroundColor(isCountingDown ? .orange : .skyIndigo)
                            .monospacedDigit()
                            .scaleEffect(isCountingDown && timeLeft <= 3 ? 1.08 : 1.0)
                            .animation(.easeInOut(duration: 0.25), value: timeLeft)
                            .padding(.top, 4)
                    }
                    .padding(.top, 40)
                    .id(currentPhaseIndex)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    // Progress bar + phase labels + elapsed time
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(UIColor.systemGray5)).frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.skyIndigo)
                                    .frame(width: geo.size.width * phaseProgress, height: 6)
                                    .animation(.linear(duration: 1), value: phaseProgress)
                            }
                        }
                        .frame(height: 6)

                        HStack(spacing: 0) {
                            ForEach(Array(phases.enumerated()), id: \.offset) { idx, _ in
                                let isCurrent = idx == currentPhaseIndex
                                let isPast    = idx < currentPhaseIndex
                                ZStack {
                                    Circle()
                                        .fill(isCurrent
                                            ? Color.skyIndigo
                                            : isPast
                                                ? Color.skyIndigo.opacity(0.35)
                                                : Color(UIColor.systemGray4))
                                        .frame(width: isCurrent ? 9 : 7, height: isCurrent ? 9 : 7)
                                    if isCurrent {
                                        Circle()
                                            .stroke(Color.skyIndigo.opacity(0.2), lineWidth: 3)
                                            .frame(width: 15, height: 15)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPhaseIndex)
                            }
                        }
                        .padding(.vertical, 4)

                        HStack {
                            Text("Phase \(currentPhaseIndex + 1) of \(phases.count)")
                                .font(.system(size: 11))
                                .foregroundColor(.skyMuted)
                            Spacer()
                        }

                        if hasStarted {
                            HStack {
                                Text(isActive ? "In progress" : "Paused")
                                    .font(.system(size: 11))
                                    .foregroundColor(isActive ? Color.skyIndigo : .skyMuted)
                                Spacer()
                                Text("Elapsed: \(formatTime(elapsedSeconds))")
                                    .font(.system(size: 11))
                                    .foregroundColor(.skyMuted)
                            }
                            .animation(.easeInOut(duration: 0.2), value: isActive)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Session type picker (only before start)
                    if sessionNotStarted {
                        HStack(spacing: 12) {
                            SessionTypeButton(title: "Full Session", subtitle: "35 min · +100 XP",
                                             isSelected: sessionType == .full) {
                                sessionType = .full
                                timeLeft = fullPhases[0].duration
                            }
                            SessionTypeButton(title: "Short Session", subtitle: "15 min · +50 XP",
                                             isSelected: sessionType == .short) {
                                sessionType = .short
                                timeLeft = shortPhases[0].duration
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        // Phase preview chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(phases.enumerated()), id: \.offset) { _, phase in
                                    PhaseChip(phase: phase)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 10)
                    }

                    // Breath circle
                    Spacer()
                    BreathCircleView(
                        breathDuration: currentPhase.breathRate,
                        isResting: currentPhase.isResting,
                        isPaused: !isActive && hasStarted
                    )
                    Spacer()

                    // End session early (shown after session starts)
                    if hasStarted {
                        Button("End Session Early") {
                            showEndConfirm = true
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.skyMuted)
                        .padding(.bottom, 8)
                    }

                    // Controls
                    HStack(spacing: 20) {
                        Button(action: toggleTimer) {
                            Image(systemName: isActive ? "pause.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 32))
                                .frame(width: 80, height: 80)
                                .background(Color.skyIndigo)
                                .clipShape(Circle())
                                .shadow(color: Color.skyIndigo.opacity(0.3), radius: 10, y: 4)
                        }

                        Button(action: skipPhase) {
                            Image(systemName: "forward.fill")
                                .foregroundColor(.skySub)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(Color(UIColor.systemGray5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToPostSession) {
                PostSessionView(sessionType: sessionType == .full ? "full" : "short",
                                durationSeconds: elapsedSeconds)
            }
            .confirmationDialog("End session early?", isPresented: $showEndConfirm, titleVisibility: .visible) {
                Button("End & Log Session", role: .destructive) { endSessionEarly() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your progress so far (\(formatTime(elapsedSeconds))) will be logged.")
            }
            .onAppear {
                timeLeft = phases[0].duration
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    // MARK: - Timer logic

    private func toggleTimer() {
        isActive ? pauseTimer() : startTimer()
    }

    private func startTimer() {
        hasStarted = true
        isActive = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            if timeLeft > 0 {
                timeLeft -= 1
                elapsedSeconds += 1
                if timeLeft == 10 || timeLeft == 5 || timeLeft == 3 {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            } else {
                advancePhase()
            }
        }
    }

    private func pauseTimer() {
        isActive = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        timer?.invalidate()
        timer = nil
    }

    private func stopTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }

    private func skipPhase() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        if currentPhaseIndex < phases.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPhaseIndex += 1
            }
            timeLeft = phases[currentPhaseIndex].duration
            showToast(phases[currentPhaseIndex].name)
        } else {
            stopTimer()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            navigateToPostSession = true
        }
    }

    private func advancePhase() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if currentPhaseIndex < phases.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPhaseIndex += 1
            }
            timeLeft = phases[currentPhaseIndex].duration
            showToast(phases[currentPhaseIndex].name)
        } else {
            stopTimer()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            navigateToPostSession = true
        }
    }

    private func showToast(_ message: String) {
        toastTask?.cancel()
        toastMessage = message
        showPhaseToast = true
        toastTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            showPhaseToast = false
        }
    }

    private func endSessionEarly() {
        stopTimer()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        navigateToPostSession = true
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

private struct PhaseChip: View {
    let phase: Phase

    private var durationLabel: String {
        String(format: "%d:%02d", phase.duration / 60, phase.duration % 60)
    }
    private var icon: String {
        phase.isResting ? "moon.fill" : "wind"
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(phase.isResting ? .skySub : .skyIndigo)
            Text(phase.name.replacingOccurrences(of: "SKY - ", with: ""))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.skySub)
            Text(durationLabel)
                .font(.system(size: 11).monospacedDigit())
                .foregroundColor(.skyMuted)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(Capsule())
    }
}

private struct SessionTypeButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .skyIndigo : .skySub)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color(red: 129/255, green: 140/255, blue: 248/255) : .skyMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color.skyIndigoLight : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.skyIndigo : Color(UIColor.systemGray4), lineWidth: 2)
            }
        }
    }
}
