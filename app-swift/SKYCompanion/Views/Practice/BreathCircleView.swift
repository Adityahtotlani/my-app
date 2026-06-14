import SwiftUI

struct BreathCircleView: View {
    let breathDuration: Double
    let isResting: Bool
    let isPaused: Bool

    @State private var isInhaling = true
    @State private var breathCount = 0
    @State private var breathTask: Task<Void, Never>?
    @State private var restPulse = false
    @State private var restPulseTask: Task<Void, Never>?

    private var expanded: Bool { isInhaling && !isResting && !isPaused }
    private var halfDuration: Double { max(breathDuration / 2, 0.5) }
    private var label: String {
        if isPaused  { return "Paused" }
        if isResting { return "Rest" }
        return isInhaling ? "Inhale" : "Exhale"
    }
    private var showCount: Bool { breathCount > 0 && !isResting && !isPaused }

    var body: some View {
        GeometryReader { proxy in
            let C = min(proxy.size.width, proxy.size.height)
            let glowDiam   = expanded ? C * 0.92 : C * 0.50
            let indigoDiam = expanded ? C * 0.56 : C * 0.33

            ZStack {
                // Outer glow (breathing phases only)
                Circle()
                    .fill(Color(red: 129/255, green: 140/255, blue: 248/255))
                    .frame(width: glowDiam, height: glowDiam)
                    .opacity(isResting ? 0 : (expanded ? 0.65 : 0.20))

                // White backing
                Circle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: C * 0.63, height: C * 0.63)
                    .shadow(color: .black.opacity(0.10), radius: 12, y: 4)

                // Rest-phase slow pulse ring
                if isResting && !isPaused {
                    Circle()
                        .stroke(Color(UIColor.systemGray3).opacity(restPulse ? 0.45 : 0.05), lineWidth: 2.5)
                        .frame(width: C * (restPulse ? 0.78 : 0.64),
                               height: C * (restPulse ? 0.78 : 0.64))
                }

                // Breath-sync pulse ring (active phases)
                if !isResting {
                    Circle()
                        .stroke(Color.skyIndigo.opacity(expanded ? 0.22 : 0), lineWidth: 2)
                        .frame(width: expanded ? C * 0.70 : C * 0.40,
                               height: expanded ? C * 0.70 : C * 0.40)
                }

                // Inner fill — gradient during active breathing, muted during rest/pause
                if isPaused {
                    Circle()
                        .fill(Color.skySub.opacity(0.6))
                        .frame(width: indigoDiam, height: indigoDiam)
                } else if isResting {
                    Circle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: C * 0.28, height: C * 0.28)
                        .opacity(0.5)
                } else {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 165/255, green: 180/255, blue: 252/255),
                                    Color.skyIndigo
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: indigoDiam / 2
                            )
                        )
                        .frame(width: indigoDiam, height: indigoDiam)
                        .opacity(expanded ? 0.92 : 0.55)
                }

                VStack(spacing: 3) {
                    Text(label)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(
                            isPaused ? .skySub :
                            isResting ? .skyMuted :
                            expanded ? .white : .skyIndigo
                        )
                    if showCount {
                        Text("\(breathCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(expanded ? .white.opacity(0.65) : Color.skyIndigo.opacity(0.55))
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showCount)
            }
            .animation(.easeInOut(duration: halfDuration), value: isInhaling)
            .animation(.easeInOut(duration: 0.6), value: isPaused)
            .animation(.easeInOut(duration: 1.0), value: isResting)
            .frame(width: C, height: C)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: isResting) { resting in
            if resting {
                stopCycle(); startRestPulse()
            } else if !isPaused {
                stopRestPulse(); startCycle()
            }
        }
        .onChange(of: isPaused) { paused in
            if paused {
                stopCycle(); stopRestPulse()
            } else if isResting {
                startRestPulse()
            } else {
                startCycle()
            }
        }
        .onChange(of: breathDuration) { _ in
            if !isResting && !isPaused { stopCycle(); startCycle() }
        }
        .onAppear {
            if isResting && !isPaused { startRestPulse() }
            else if !isResting && !isPaused { startCycle() }
        }
        .onDisappear { stopCycle(); stopRestPulse() }
    }

    // MARK: - Breath cycle

    private func startCycle() {
        stopCycle()
        isInhaling = true
        breathCount = 1
        let half = halfDuration
        breathTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(half))
                guard !Task.isCancelled else { return }
                isInhaling = false
                try? await Task.sleep(for: .seconds(half))
                guard !Task.isCancelled else { return }
                isInhaling = true
                breathCount += 1
            }
        }
    }

    private func stopCycle() {
        breathTask?.cancel()
        breathTask = nil
    }

    // MARK: - Rest pulse

    private func startRestPulse() {
        stopRestPulse()
        restPulse = false
        restPulseTask = Task { @MainActor in
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 3.0)) { restPulse = true }
                try? await Task.sleep(for: .seconds(3.0))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 3.0)) { restPulse = false }
                try? await Task.sleep(for: .seconds(3.0))
            }
        }
    }

    private func stopRestPulse() {
        restPulseTask?.cancel()
        restPulseTask = nil
        restPulse = false
    }
}
