// ProgressRingView.swift ⌘ @jonathaxs

import SwiftUI

struct ProgressRingView: View {
    let progress: Double          // 0.0 ... 1.0

    var size: CGFloat = 120
    var lineWidth: CGFloat = 12
    var showsPercentage: Bool = true

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: clampedProgress)

            if showsPercentage {
                Text("\(Int(clampedProgress * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel(Copy.progressAccessibilityLabel)
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
    }
}

#Preview {
    VStack(spacing: 24) {
        ProgressRingView(progress: 0.15)
        ProgressRingView(progress: 0.65, size: 140, lineWidth: 14)
        ProgressRingView(progress: 1.0, showsPercentage: false)
    }
    .padding()
}
