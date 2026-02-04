//  ProgressRingView.swift ⌘ @jonathaxs

import SwiftUI

struct ProgressRingView: View {
    let progress: Double          // 0.0 ... 1.0
    let lineWidth: CGFloat = 12

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.secondary.opacity(0.2),
                    lineWidth: lineWidth
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: clampedProgress)

            // Center label (percentage)
            Text("\(Int(clampedProgress * 100))%")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(width: 120, height: 120)
        .accessibilityElement()
        .accessibilityLabel("Daily progress")
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
    }
}

#Preview {
    ProgressRingView(progress: 0.65)
}
