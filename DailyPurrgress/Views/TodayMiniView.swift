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
        Text("Daily habits don’t have to be loud.\nSometimes, they just purr.")
            .font(.headline)
            .multilineTextAlignment(.center)
    }

    var catMood: some View {
        VStack(spacing: 10) {
            Text(model.tier.emoji)
                .font(.system(size: 72))

            Text(model.tier.title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(model.tier.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    var progressInfo: some View {
        VStack(spacing: 6) {
            Text("\(model.currentML) / \(model.dailyGoalML) ml")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(Int(model.progress * 100))%")
                .font(.title2)
                .fontWeight(.bold)
        }
    }

    var actions: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    model.addStep()
                }
            } label: {
                Text("Log +\(model.stepML) ml")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button("Reset") {
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
