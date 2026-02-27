//  ProgressRingView.swift ⌘
//  Created by @jonathaxs
//  Swift Student Challenge 2026

import SwiftUI

struct ProgressRingView: View {
    let progress: Double          // 0.0 ... 1.0

    var size: CGFloat = 120
    var lineWidth: CGFloat = 12
    var showsPercentage: Bool = true

    /// Optional override used for small interaction moments (e.g. ring tap highlight).
    /// When non-nil, it replaces the computed tier color.
    var overrideRingColor: Color? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var ringColor: Color {
        if let overrideRingColor {
            return overrideRingColor
        }

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
                    .foregroundStyle(ringColor)
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: clampedProgress)
                    .accessibilityHidden(true)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel(Text(NSLocalizedString("a11y.progressRing.label", comment: "Accessibility label for overall daily progress ring")))
        .accessibilityHint(Text(NSLocalizedString("a11y.progressRing.hint", comment: "Accessibility hint describing the progress ring")))
        .accessibilityValue(
            Text(
                String(
                    format: NSLocalizedString(
                        "a11y.progressRing.percentCompleted.fmt",
                        comment: "Accessibility value describing percent completed"
                    ),
                    Int(clampedProgress * 100)
                )
            )
        )
    }
}

#Preview {
    VStack(spacing: 24) {
        ProgressRingView(progress: 0.15)
        ProgressRingView(progress: 0.65, size: 140, lineWidth: 14, overrideRingColor: .purple)
        ProgressRingView(progress: 1.0, showsPercentage: false)
    }
    .padding()
}
