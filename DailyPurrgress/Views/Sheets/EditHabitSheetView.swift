// EditHabitSheetView.swift ⌘ @jonathaxs

import SwiftUI

struct EditHabitSheetView: View {
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(habitsStore.habits) { habit in
                        NavigationLink {
                            EditHabitDetailView(habit: habit)
                                .environmentObject(habitsStore)
                        } label: {
                            HStack(spacing: 10) {
                                Text(habit.emoji)
                                    .font(.headline)
                                    .accessibilityHidden(true)

                                Text(habit.name)

                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct EditHabitDetailView: View {
    let habit: Habit

    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    @State private var emoji: String
    @State private var name: String
    @State private var unit: String
    @State private var goalText: String
    @State private var stepText: String

    init(habit: Habit) {
        self.habit = habit
        _emoji = State(initialValue: habit.emoji)
        _name = State(initialValue: habit.name)
        _unit = State(initialValue: habit.unit)
        _goalText = State(initialValue: String(habit.goal))
        _stepText = State(initialValue: String(habit.step))
    }

    private var trimmedEmoji: String {
        emoji.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1).description
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedUnit: String {
        unit.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var goalValue: Int? {
        Int(goalText)
    }

    private var stepValue: Int? {
        Int(stepText)
    }

    private var safeGoal: Int {
        goalValue ?? 0
    }

    private var safeStep: Int {
        stepValue ?? 0
    }

    private var canSave: Bool {
        guard !trimmedEmoji.isEmpty else { return false }
        guard !trimmedName.isEmpty else { return false }
        guard !trimmedUnit.isEmpty else { return false }
        guard let goalValue, goalValue > 0 else { return false }
        guard let stepValue, stepValue > 0 else { return false }
        return stepValue <= goalValue
    }

    var body: some View {
        Form {
            Section() {
                TextField("", text: $emoji)
            } header: {
                Text("Emoji")
            }
            
            Section() {
                TextField("", text: $name)
            } header: {
                Text("Name")
            }

            Section() {
                TextField("", text: $unit)
            } header: {
                Text("Measure")
            }
            
            Section() {
                TextField("", text: $goalText)
                    .keyboardType(.numberPad)
            } header: {
                Text("Target")
            }

            Section {
                TextField("", text: $stepText)
                    .keyboardType(.numberPad)
            } header: {
                Text("Log step")
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let didUpdate = habitsStore.updateHabit(
                        id: habit.id,
                        name: trimmedName,
                        emoji: trimmedEmoji,
                        unit: trimmedUnit,
                        goal: safeGoal,
                        step: safeStep
                    )

                    if didUpdate {
                        dismiss()
                    }
                }
                .disabled(!canSave)
            }
        }
    }
}

#Preview {
    EditHabitSheetView()
        .environmentObject(HabitsStore())
}
