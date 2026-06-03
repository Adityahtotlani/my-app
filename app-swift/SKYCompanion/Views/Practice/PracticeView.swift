import SwiftUI

private struct Phase {
    let id: String
    let name: String
    let duration: Int      // seconds
    let breathRate: Double // seconds per full breath cycle
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
    @State private var currentPhaseIndex = 0
    @State private var timeLeft = 0
    @State private var timer: Timer?
    @State private var navigateToPostSession = false
    @State private var totalDuration = 0

    enum SessionType { case full, short }

    private var phases: [Phase] { sessionType == .full ? fullPhases : shortPhases }
    private var currentPhase: Phase { phases[currentPhaseIndex] }
    private var sessionNotStarted: Bool { !isActive && currentPhaseIndex == 0 && timeLeft == phases[0].duration }

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

                VStack(spacing: 0) {
                    // Phase name + timer
                    VStack(spacing: 10) {
                        Text(currentPhase.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.skyText)
                        Text(formatTime(timeLeft))
                            .font(.system(size: 52, weight: .light))
                            .foregroundColor(.skyIndigo)
                            .monospacedDigit()
                    }
                    .padding(.top, 40)

                    // Phase progress bar
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(UIColor.systemGray5)).frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.skyIndigo)
                                    .frame(width: geo.size.width * phaseProgress, height: 6)
                            }
                        }
                        .frame(height: 6)

                        HStack {
                            ForEach(phases, id: \.id) { phase in
                                Text(phase.name.components(separatedBy: " ").first ?? "")
                                    .font(.system(size: 10))
                                    .foregroundColor(phase.id == currentPhase.id ? .skyIndigo : .skyMuted)
                                    .fontWeight(phase.id == currentPhase.id ? .semibold : .regular)
                                    .frame(maxWidth: .infinity)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Session type picker (only before start)
                    if sessionNotStarted {
                        HStack(spacing: 12) {
                            SessionTypeButton(title: "Full Session", subtitle: "35 min",
                                             isSelected: sessionType == .full) {
                                sessionType = .full
                                timeLeft = fullPhases[0].duration
                            }
                            SessionTypeButton(title: "Short Session", subtitle: "15 min",
                                             isSelected: sessionType == .short) {
                                sessionType = .short
                                timeLeft = shortPhases[0].duration
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }

                    // Breath circle
                    Spacer()
                    BreathCircleView(
                        breathDuration: currentPhase.breathRate,
                        isResting: currentPhase.isResting
                    )
                    Spacer()

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
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToPostSession) {
                PostSessionView(sessionType: sessionType == .full ? "full" : "short",
                                durationSeconds: totalDuration)
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
        isActive ? stopTimer() : startTimer()
    }

    private func startTimer() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                skipPhase()
            }
        }
    }

    private func stopTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }

    private func skipPhase() {
        if currentPhaseIndex < phases.count - 1 {
            currentPhaseIndex += 1
            timeLeft = phases[currentPhaseIndex].duration
        } else {
            stopTimer()
            totalDuration = phases.reduce(0) { $0 + $1.duration }
            navigateToPostSession = true
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
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
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.skyIndigo : Color(UIColor.systemGray4), lineWidth: 2))
        }
    }
}
