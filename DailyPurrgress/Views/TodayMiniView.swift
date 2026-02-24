// TodayMiniView.swift ⌘
//  Created by @jonathaxs.
//  Swift Student Challenge 2026

import SwiftUI

struct TodayMiniView: View {
    // MARK: - Dependencies
    @EnvironmentObject private var habitsStore: HabitsStore

    // MARK: - UI State
    @State private var isPresentingEditHabit: Bool = false
    @State private var isConfirmingResetAll: Bool = false
    @State private var isPresentingInspirationalMessageEditor: Bool = false
    @State private var isPresentingCatTierEditor: Bool = false
    @State private var isRingPulsing: Bool = false

    @AppStorage("DailyPurrgress.inspirationalMessageOverride")
    private var inspirationalMessageOverride: String = ""

    // Increment to trigger a subtle haptic on log actions.
    @State private var hapticTrigger: Int = 0

    // Increment to trigger a double haptic when a reset is confirmed.
    @State private var resetHapticTrigger: Int = 0

    // Triggers a quick wiggle animation on the cat when the inspirational message is tapped.
    @State private var catWiggleTrigger: Int = 0
    @State private var isCatWiggling: Bool = false

    // MARK: - Derived State
    private var overallProgress: Double {
        let valid = habitsStore.habits.filter { $0.goal > 0 }
        guard valid.isEmpty == false else { return 0 }

        let sum = valid.reduce(0.0) { partial, habit in
            partial + habit.progress
        }

        return min(max(sum / Double(valid.count), 0), 1)
    }

    private var overallTier: CatTier {
        CatTier.from(progress: overallProgress)
    }

    private func triggerCatWiggle() {
        // Trigger haptic + a small cat wiggle.
        hapticTrigger += 1
        catWiggleTrigger += 1
        isCatWiggling = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isCatWiggling = false
        }
    }

    private func triggerRingPulse() {
        isRingPulsing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            isRingPulsing = false
        }
    }

    var body: some View {
        NavigationStack {
            content
                .padding()
                .sensoryFeedback(.impact, trigger: hapticTrigger)
                .sensoryFeedback(.warning, trigger: resetHapticTrigger)
                .sheet(isPresented: $isPresentingEditHabit) {
                    EditHabitSheetView()
                        .environmentObject(habitsStore)
                }
                .sheet(isPresented: $isPresentingInspirationalMessageEditor) {
                    InspirationalMessageSheetView(
                        defaultMessage: NSLocalizedString(
                            "todayMini.inspirationalMessage.default",
                            comment: "Inspirational Message default"
                        )
                    )
                }
                .sheet(isPresented: $isPresentingCatTierEditor) {
                    CatTierSheetView()
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sections

private extension TodayMiniView {
    private var inspirationalMessageText: String {
        let defaultMessage = NSLocalizedString(
            "todayMini.inspirationalMessage.default",
            comment: "Inspirational Message default"
        )

        let trimmedOverride = inspirationalMessageOverride.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedOverride.isEmpty ? defaultMessage : trimmedOverride
    }

    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                inspirationalMessage
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 18) {
                    Button {
                        isPresentingCatTierEditor = true
                    } label: {
                        CatMoodView(tier: overallTier)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(NSLocalizedString("a11y.catMood.label", comment: "")))
                    .accessibilityHint(Text(NSLocalizedString("a11y.catMood.hint", comment: "")))

                    Button {
                        triggerRingPulse()
                    } label: {
                        ProgressRingView(
                            progress: overallProgress,
                            size: 108,
                            lineWidth: 12
                        )
                        .scaleEffect(isRingPulsing ? 1.08 : 1.0)
                        .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isRingPulsing)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(NSLocalizedString("a11y.progressRing.label", comment: "")))
                    .accessibilityHint(Text(NSLocalizedString("a11y.progressRing.hint", comment: "")))
                }
                .frame(maxWidth: .infinity)
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
                    .frame(height: 15)

                ForEach(habitsStore.habits) { habit in
                    HabitRowView(
                        habit: habit,
                        onLogStep: {
                            // Haptic tick + animated progress update.
                            hapticTrigger += 1
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                habitsStore.logStep(for: habit.id)
                            }
                        },
                        onReset: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                habitsStore.resetHabit(id: habit.id)
                            }
                        },
                        onSetCurrent: { newValue in
                            withAnimation(.easeInOut(duration: 0.12)) {
                                habitsStore.setCurrent(newValue, for: habit.id)
                            }
                        }
                    )
                    .frame(maxWidth: 330)
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Spacer()
                    .frame(height: 14)

                HStack(spacing: 12) {
                    Button(NSLocalizedString("common.action.resetAll", comment: "")) {
                        isConfirmingResetAll = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button(NSLocalizedString("common.action.editHabits", comment: "")) {
                        isPresentingEditHabit = true
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: 330)
                .frame(maxWidth: .infinity, alignment: .center)
                .controlSize(.large)
                .confirmationDialog(
                    NSLocalizedString("common.confirm.resetAll.title", comment: ""),
                    isPresented: $isConfirmingResetAll,
                    titleVisibility: .visible
                ) {
                    Button(NSLocalizedString("common.action.resetAll", comment: ""), role: .destructive) {
                        // Double haptic only when the reset actually happens.
                        Task { @MainActor in
                            resetHapticTrigger += 1
                            try? await Task.sleep(nanoseconds: 120_000_000)
                            resetHapticTrigger += 1
                        }

                        // Clear all habits' progress for today.
                        withAnimation(.easeInOut(duration: 0.2)) {
                            habitsStore.resetAll()
                        }
                    }
                    Button(NSLocalizedString("common.action.cancel", comment: ""), role: .cancel) {}
                } message: {
                    Text(NSLocalizedString("common.confirm.resetAll.message", comment: ""))
                }
            }
        }
    }

    var inspirationalMessage: some View {
        Button {
            isPresentingInspirationalMessageEditor = true
        } label: {
            Text(inspirationalMessageText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .controlSize(.large)
        .accessibilityLabel(Text("Inspirational message"))
        .accessibilityHint(Text("Double tap to edit"))
    }
}

// MARK: - Preview

#Preview {
    TodayMiniView()
        .environmentObject(HabitsStore())
}
