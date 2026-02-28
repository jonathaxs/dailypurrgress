//  AddHabitSheetView.swift ⌘
//  Created by @jonathaxs.
//  Swift Student Challenge 2026

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
    // Haptic trigger for Save action
    @State private var saveHapticTick: Int = 0

    // MARK: - Validation Helpers

    private var canAddMore: Bool {
        habitsStore.habits.count < HabitsStore.maxHabits
    }

    private var goal: Int? {
        Int(goalText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var step: Int? {
        Int(stepText.trimmingCharacters(in: .whitespacesAndNewlines))
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

    private var normalizedName: String {
        trimmedName.lowercased()
    }

    private var isDuplicateName: Bool {
        guard !normalizedName.isEmpty else { return false }
        return habitsStore.habits.contains {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalizedName
        }
    }

    private var isDuplicateEmoji: Bool {
        guard !trimmedEmoji.isEmpty else { return false }
        return habitsStore.habits.contains {
            String($0.emoji.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)) == trimmedEmoji
        }
    }

    private var isValid: Bool {
        guard canAddMore else { return false }
        guard !trimmedName.isEmpty else { return false }
        guard !trimmedUnit.isEmpty else { return false }
        guard !trimmedEmoji.isEmpty else { return false }
        guard !isDuplicateName else { return false }
        guard !isDuplicateEmoji else { return false }
        guard let goal, let step else { return false }
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
                    if isDuplicateEmoji {
                        Text(NSLocalizedString(
                            "addHabitSheet.validation.duplicateEmoji",
                            comment: "Shown when the chosen emoji is already used by another habit"
                        ))
                        .font(.footnote)
                        .foregroundStyle(.red)
                    }

                    TextField(
                        NSLocalizedString("addHabitSheet.section.emoji.placeholder", comment: "Add habit emoji placeholder"),
                        text: $emoji
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }

                Section(NSLocalizedString("addHabitSheet.section.name.title", comment: "Add habit section title: name")) {
                    if isDuplicateName {
                        Text(NSLocalizedString(
                            "addHabitSheet.validation.duplicateName",
                            comment: "Shown when the chosen habit name is already used by another habit"
                        ))
                        .font(.footnote)
                        .foregroundStyle(.red)
                    }

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
                        guard let goal, let step else { return }

                        let created = habitsStore.addHabit(
                            name: trimmedName,
                            emoji: trimmedEmoji,
                            unit: trimmedUnit,
                            goal: goal,
                            step: step
                        )

                        if created {
                            saveHapticTick += 1
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                    .tint(.blue)
                }
            }
        }
        .sensoryFeedback(.success, trigger: saveHapticTick)
    }
}
