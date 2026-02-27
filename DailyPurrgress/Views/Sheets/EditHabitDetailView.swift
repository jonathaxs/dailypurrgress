//  EditHabitDetailView.swift ⌘
//  Created by @jonathaxs.
//  Swift Student Challenge 2026

import SwiftUI

struct EditHabitDetailView: View {
    // MARK: - Input
    let habit: Habit

    // MARK: - Environment
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - Draft Fields
    // I keep draft state so the user can cancel without changing the stored habit.
    @State private var emoji: String
    @State private var name: String
    @State private var unit: String
    @State private var goalText: String
    @State private var stepText: String

    // MARK: - Init
    init(habit: Habit) {
        self.habit = habit
        _emoji = State(initialValue: habit.emoji)
        _name = State(initialValue: habit.name)
        _unit = State(initialValue: habit.unit)
        _goalText = State(initialValue: String(habit.goal))
        _stepText = State(initialValue: String(habit.step))
    }

    // MARK: - Validation Helpers
    private var isNameAndEmojiLocked: Bool {
        habit.isProtected
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

    // MARK: - View
    var body: some View {
        Form {
            if !isNameAndEmojiLocked {
                Section {
                    TextField("", text: $emoji)
                } header: {
                    Text(NSLocalizedString("editHabitDetail.field.emoji", comment: "Edit habit field label: Emoji"))
                }
            }

            if !isNameAndEmojiLocked {
                Section {
                    TextField("", text: $name)
                } header: {
                    Text(NSLocalizedString("editHabitDetail.field.name", comment: "Edit habit field label: Name"))
                }
            }

            Section {
                TextField("", text: $unit)
            } header: {
                Text(NSLocalizedString("editHabitDetail.field.measure", comment: "Edit habit field label: Measure"))
            }

            Section {
                TextField("", text: $goalText)
                    .keyboardType(.numberPad)
            } header: {
                Text(NSLocalizedString("editHabitDetail.field.target", comment: "Edit habit field label: Target"))
            }

            Section {
                TextField("", text: $stepText)
                    .keyboardType(.numberPad)
            } header: {
                Text(NSLocalizedString("editHabitDetail.field.logStep", comment: "Edit habit field label: Log step"))
            } footer: {
                if isNameAndEmojiLocked {
                    Text(
                        NSLocalizedString(
                            "editHabitDetail.footer.waterNameEmojiLocked",
                            comment: "Footer note shown only for the Water habit, explaining name/emoji are locked."
                        )
                    )
                    .padding(.top, 10)
                }
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(NSLocalizedString("common.action.save", comment: "Save button title")) {
                    let didUpdate = habitsStore.updateHabit(
                        id: habit.id,
                        name: isNameAndEmojiLocked ? habit.name : trimmedName,
                        emoji: isNameAndEmojiLocked ? habit.emoji : trimmedEmoji,
                        unit: trimmedUnit,
                        goal: safeGoal,
                        step: safeStep
                    )

                    if didUpdate {
                        dismiss()
                    }
                }
                .disabled(!canSave)
                .tint(.blue)
            }
        }
    }
}
