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

    // Increment to trigger a subtle haptic on log actions.
    @State private var hapticTrigger: Int = 0

    // Triggers a quick wiggle animation on the cat when the opening copy is tapped.
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

    var body: some View {
        NavigationStack {
            content
                .padding()
                .sensoryFeedback(.impact, trigger: hapticTrigger)
                .sheet(isPresented: $isPresentingEditHabit) {
                    EditHabitSheetView()
                        .environmentObject(habitsStore)
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sections

private extension TodayMiniView {
    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                openingCopy
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 18) {
                    CatMoodView(tier: overallTier)
                        .rotationEffect(isCatWiggling ? .degrees(-7) : .degrees(0))
                        .scaleEffect(isCatWiggling ? 1.04 : 1.0)
                        .animation(.spring(response: 0.22, dampingFraction: 0.35), value: isCatWiggling)
                        .id(catWiggleTrigger)

                    ProgressRingView(
                        progress: overallProgress,
                        size: 108,
                        lineWidth: 12
                    )
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
                    .tint(.green)
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

    var openingCopy: some View {
        Button {
            // Trigger haptic + a small cat wiggle.
            hapticTrigger += 1
            catWiggleTrigger += 1
            isCatWiggling = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isCatWiggling = false
            }
        } label: {
            Text(NSLocalizedString("todayMini.opening.text", comment: ""))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}

// MARK: - Preview

#Preview {
    TodayMiniView()
        .environmentObject(HabitsStore())
}
