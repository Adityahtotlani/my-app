import SwiftUI

struct BreathCircleView: View {
    let breathDuration: Double  // seconds for one inhale
    let isResting: Bool

    @State private var expanded = false

    private var scale: Double { expanded ? 1.4 : 1.0 }
    private var opacity: Double { expanded ? 0.8 : 0.3 }

    var body: some View {
        ZStack {
            // Glow ring
            Circle()
                .fill(Color(red: 129/255, green: 140/255, blue: 248/255))
                .scaleEffect(scale)
                .opacity(opacity)

            // White ring
            Circle()
                .fill(Color.white)
                .frame(width: circleSize * 0.8, height: circleSize * 0.8)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)

            // Inner indigo circle
            Circle()
                .fill(Color.skyIndigo)
                .frame(width: circleSize * 0.6, height: circleSize * 0.6)
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .frame(width: circleSize, height: circleSize)
        .onChange(of: isResting) { resting in
            if resting {
                withAnimation(.easeInOut(duration: 1)) { expanded = false }
            } else {
                startAnimation()
            }
        }
        .onChange(of: breathDuration) { _ in
            if !isResting { startAnimation() }
        }
        .onAppear {
            if !isResting { startAnimation() }
        }
    }

    private var circleSize: CGFloat { UIScreen.main.bounds.width * 0.7 }

    private func startAnimation() {
        let half = max(breathDuration / 2, 0.5)
        withAnimation(.easeInOut(duration: half).repeatForever(autoreverses: true)) {
            expanded = true
        }
    }
}
