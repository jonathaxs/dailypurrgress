// TodayMiniView.swift ⌘ @jonathaxs

import SwiftUI

struct TodayMiniView: View {
    @EnvironmentObject private var habitsStore: HabitsStore

    @State private var isPresentingAddHabit: Bool = false
    @State private var isPresentingManageHabits: Bool = false

    @State private var hapticTrigger: Int = 0

    private var canAddHabit: Bool {
        habitsStore.habits.count < HabitsStore.maxHabits
    }

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
            .navigationTitle("DailyPurrgress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresentingManageHabits = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(habitsStore.habits.count <= 1)
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        // Placeholder: Edit Habit sheet will be implemented next.
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .disabled(true)
                    .opacity(0.6)
                    .accessibilityLabel("Edit habits")

                    Button {
                        isPresentingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!canAddHabit)
                }
            }
            .sheet(isPresented: $isPresentingAddHabit) {
                AddHabitSheetView()
                    .environmentObject(habitsStore)
            }
            .sheet(isPresented: $isPresentingManageHabits) {
                ManageHabitsSheetView()
                    .environmentObject(habitsStore)
            }
        }
    }
}

// MARK: - Sections

private extension TodayMiniView {
    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                openingCopy
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(spacing: 12) {
                    CatMoodView(tier: overallTier)

                    ProgressRingView(
                        progress: overallProgress,
                        size: 108,
                        lineWidth: 12
                    )
                }
                .frame(maxWidth: .infinity)

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
