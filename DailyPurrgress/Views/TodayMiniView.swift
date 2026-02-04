// TodayMiniView.swift ⌘ @jonathaxs

import SwiftUI

struct TodayMiniView: View {
    @State private var model = MiniProgressModel()

    var body: some View {
        VStack(spacing: 20) {
            openingCopy

            catMood

            progressInfo

            actions
        }
        .padding()
    }
}

// MARK: - Sections

private extension TodayMiniView {
    var openingCopy: some View {
        Text(Copy.opening)
            .font(.headline)
            .multilineTextAlignment(.center)
    }

    var catMood: some View {
        CatMoodView(tier: model.tier)
    }

    var progressInfo: some View {
        VStack(spacing: 10) {
            ProgressRingView(progress: model.progress)

            Text("\(model.currentML) / \(model.dailyGoalML) ml")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    var actions: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    model.addStep()
                }
            } label: {
                Text(Copy.logStep(model.stepML))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button(Copy.reset) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    model.reset()
                }
            }
            .buttonStyle(.bordered)
            .disabled(model.currentML == 0)
        }
    }
}

// MARK: - Preview

#Preview {
    TodayMiniView()
}
