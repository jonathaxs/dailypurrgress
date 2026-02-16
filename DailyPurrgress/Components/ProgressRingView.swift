// ProgressRingView.swift ⌘ @jonathaxs

import SwiftUI

struct ProgressRingView: View {
    let progress: Double          // 0.0 ... 1.0

    var size: CGFloat = 120
    var lineWidth: CGFloat = 12
    var showsPercentage: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var ringColor: Color {
        switch clampedProgress {
        case ..<0.30:
            return .red
        case ..<0.60:
            return .orange
        case ..<1.0:
            return .green
        default:
            return .blue
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: clampedProgress)

            if showsPercentage {
                Text("\(Int(clampedProgress * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: clampedProgress)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel(Copy.progressAccessibilityLabel)
        .accessibilityHint(Copy.progressAccessibilityHint)
        .accessibilityValue(Copy.percentCompletedValue(Int(clampedProgress * 100)))
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
