// AddHabitSheetView.swift ⌘ @jonathaxs

import SwiftUI

struct AddHabitSheetView: View {
    // MARK: - Environment
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - Draft Fields
    // Using local draft state keeps edits isolated until the user taps Save.

    @State private var name: String = ""
    @State private var unit: String = ""
    @State private var goalText: String = ""
    @State private var stepText: String = ""
    @State private var emoji: String = ""

    // MARK: - Validation Helpers

    private var canAddMore: Bool {
        habitsStore.habits.count < HabitsStore.maxHabits
    }

    private var goal: Int {
        Int(goalText) ?? 0
    }

    private var step: Int {
        Int(stepText) ?? 0
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedUnit: String {
        unit.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedEmoji: String {
        String(emoji.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1))
    }

    private var isValid: Bool {
        guard canAddMore else { return false }
        guard !trimmedName.isEmpty else { return false }
        guard !trimmedUnit.isEmpty else { return false }
        guard !trimmedEmoji.isEmpty else { return false }
        guard goal > 0, step > 0, step <= goal else { return false }
        return true
    }

    private var limitReachedText: String {
        String(
            format: NSLocalizedString(
                "addHabitSheet.limitReached.fmt",
                comment: "Shown when the user reaches the max number of habits. Uses one %d placeholder."
            ),
            HabitsStore.maxHabits
        )
    }

    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("addHabitSheet.section.emoji.title", comment: "Add habit section title: emoji")) {
                    TextField(
                        NSLocalizedString("addHabitSheet.section.emoji.placeholder", comment: "Add habit emoji placeholder"),
                        text: $emoji
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }

                Section(NSLocalizedString("addHabitSheet.section.name.title", comment: "Add habit section title: name")) {
                    TextField(
                        NSLocalizedString("addHabitSheet.section.name.placeholder", comment: "Add habit name placeholder"),
                        text: $name
                    )
                    .textInputAutocapitalization(.words)
                }

                Section(NSLocalizedString("addHabitSheet.section.unit.title", comment: "Add habit section title: measure")) {
                    TextField(
                        NSLocalizedString("addHabitSheet.section.unit.placeholder", comment: "Add habit measure placeholder"),
                        text: $unit
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }

                Section(NSLocalizedString("addHabitSheet.section.goal.title", comment: "Add habit section title: target")) {
                    TextField(
                        NSLocalizedString("addHabitSheet.section.goal.placeholder", comment: "Add habit target placeholder"),
                        text: $goalText
                    )
                    .keyboardType(.numberPad)
                }

                Section(NSLocalizedString("addHabitSheet.section.step.title", comment: "Add habit section title: log step")) {
                    TextField(
                        NSLocalizedString("addHabitSheet.section.step.placeholder", comment: "Add habit log step placeholder"),
                        text: $stepText
                    )
                    .keyboardType(.numberPad)
                }

                if !canAddMore {
                    Text(limitReachedText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(NSLocalizedString("addHabitSheet.title", comment: "Add Habit navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.action.cancel", comment: "Cancel button title")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.action.save", comment: "Save button title")) {
                        let created = habitsStore.addHabit(
                            name: trimmedName,
                            emoji: trimmedEmoji,
                            unit: trimmedUnit,
                            goal: goal,
                            step: step
                        )

                        if created {
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                    .tint(.blue)
                }
            }
        }
    }
}
