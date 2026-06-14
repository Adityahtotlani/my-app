import SwiftUI

struct BreathCircleView: View {
    let breathDuration: Double
    let isResting: Bool
    let isPaused: Bool

    @State private var isInhaling = true
    @State private var breathCount = 0
    @State private var breathTask: Task<Void, Never>?

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
                Circle()
                    .fill(Color(red: 129/255, green: 140/255, blue: 248/255))
                    .frame(width: glowDiam, height: glowDiam)
                    .opacity(expanded ? 0.65 : 0.20)

                Circle()
                    .fill(Color.white)
                    .frame(width: C * 0.63, height: C * 0.63)
                    .shadow(color: .black.opacity(0.10), radius: 12, y: 4)

                Circle()
                    .fill(isPaused ? Color.skySub : Color.skyIndigo)
                    .frame(width: indigoDiam, height: indigoDiam)
                    .opacity(expanded ? 0.90 : 0.50)

                VStack(spacing: 3) {
                    Text(label)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(expanded ? .white : (isPaused ? .skySub : .skyIndigo))
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
            if resting { stopCycle() } else if !isPaused { startCycle() }
        }
        .onChange(of: isPaused) { paused in
            if paused { stopCycle() } else if !isResting { startCycle() }
        }
        .onChange(of: breathDuration) { _ in
            if !isResting && !isPaused { stopCycle(); startCycle() }
        }
        .onAppear {
            if !isResting && !isPaused { startCycle() }
        }
        .onDisappear { stopCycle() }
    }

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
}
