// TodayMiniView.swift ⌘ @jonathaxs

import SwiftUI

struct TodayMiniView: View {
    @EnvironmentObject private var habitsStore: HabitsStore

    @State private var isPresentingEditHabit: Bool = false
    @State private var isConfirmingResetAll: Bool = false

    @State private var hapticTrigger: Int = 0

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
                    .frame(height: 15)

                HStack(spacing: 12) {
                    Button("Reset All") {
                        isConfirmingResetAll = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button("Edit Habits") {
                        isPresentingEditHabit = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
                .frame(maxWidth: 330)
                .frame(maxWidth: .infinity, alignment: .center)
                .controlSize(.large)
                .confirmationDialog(
                    "Reset all habits?",
                    isPresented: $isConfirmingResetAll,
                    titleVisibility: .visible
                ) {
                    Button("Reset All", role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            habitsStore.resetAll()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will reset the progress for all habits.")
                }
            }
        }
    }

    var openingCopy: some View {
        Text(Copy.opening)
            .font(.headline)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Preview

#Preview {
    TodayMiniView()
        .environmentObject(HabitsStore())
}
