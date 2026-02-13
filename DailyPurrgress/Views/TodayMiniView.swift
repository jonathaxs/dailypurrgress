// TodayMiniView.swift ⌘ @jonathaxs

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct TodayMiniView: View {
    @EnvironmentObject private var habitsStore: HabitsStore

    private var water: Habit {
        habitsStore.habits.first(where: { $0.isProtected }) ?? .waterDefault()
    }

    private var tier: CatTier {
        CatTier.from(progress: water.progress)
    }

    var body: some View {
        VStack(spacing: 24) {
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
        CatMoodView(tier: tier)
    }

    var progressInfo: some View {
        VStack(spacing: 12) {
            ProgressRingView(
                progress: water.progress,
                size: 132,
                lineWidth: 14
            )

            Text(Copy.progressLine(current: water.current, goal: water.goal))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if !water.isComplete {
                Text(Copy.remaining(water.remaining))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(Copy.remainingAccessibilityLabel)
                    .accessibilityValue(Copy.remaining(water.remaining))
                    .accessibilityHint(Copy.remainingAccessibilityHint)
            }
        }
    }

    func triggerHaptic() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    var actions: some View {
        VStack(spacing: 14) {
            Button {
                guard !water.isComplete else { return }
                triggerHaptic()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    habitsStore.logStep(for: water.id)
                }
            } label: {
                Text(Copy.logStep(water.step))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(water.isComplete)
            .opacity(water.isComplete ? 0.6 : 1.0)
            .accessibilityLabel(Copy.logWaterAccessibilityLabel)
            .accessibilityValue(Copy.millilitersValue(water.step))
            .accessibilityHint(Copy.logWaterAccessibilityHint)

            if water.isComplete {
                Text(Copy.goalReached)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button(Copy.reset) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    habitsStore.resetHabit(id: water.id)
                }
            }
            .buttonStyle(.bordered)
            .disabled(water.current == 0)
            .accessibilityLabel(Copy.resetTodayAccessibilityLabel)
            .accessibilityHint(Copy.resetTodayAccessibilityHint)
        }
    }
}

// MARK: - Preview

#Preview {
    TodayMiniView()
        .environmentObject(HabitsStore())
}
