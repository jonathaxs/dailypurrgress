// EditHabitSheetView.swift ⌘ @jonathaxs

import SwiftUI

struct EditHabitSheetView: View {
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    @State private var editMode: EditMode = .inactive
    @State private var isPresentingAddHabit: Bool = false

    private var canAddMore: Bool {
        habitsStore.habits.count < HabitsStore.maxHabits
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(habitsStore.habits) { habit in
                        NavigationLink {
                            EditHabitDetailView(habit: habit)
                                .environmentObject(habitsStore)
                        } label: {
                            row(for: habit)
                        }
                        .deleteDisabled(habit.isProtected)
                    }
                    .onDelete(perform: delete)
                } header: {
                    Text(NSLocalizedString("sheet.editHabits.section.title", comment: "Header title for habits list section"))
                } footer: {
                    Text(NSLocalizedString("sheet.editHabits.footer.waterProtected", comment: "Footer note explaining that Water cannot be deleted"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle(NSLocalizedString("sheet.editHabits.title", comment: "Edit habits sheet navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("action.back", comment: "Back button title")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(NSLocalizedString("action.add", comment: "Add button title")) {
                            isPresentingAddHabit = true
                        }
                        .disabled(!canAddMore)

                        Button(editMode.isEditing
                               ? NSLocalizedString("action.done", comment: "Done button title")
                               : NSLocalizedString("action.delete", comment: "Enter delete mode button title")) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                editMode = editMode.isEditing ? .inactive : .active
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddHabit) {
                AddHabitSheetView()
                    .environmentObject(habitsStore)
            }
        }
    }
}

// MARK: - Delete

private extension EditHabitSheetView {
    func delete(at offsets: IndexSet) {
        let habits = habitsStore.habits

        for index in offsets {
            guard habits.indices.contains(index) else { continue }
            let habit = habits[index]
            guard !habit.isProtected else { continue }
            habitsStore.deleteHabit(id: habit.id)
        }
    }
}

// MARK: - Row

private extension EditHabitSheetView {
    @ViewBuilder
    func row(for habit: Habit) -> some View {
        HStack(spacing: 12) {
            Text(habit.emoji)
                .font(.headline)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)

                Text("\(habit.current) / \(habit.goal) \(habit.unit)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
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
            Section {
                TextField("", text: $emoji)
            } header: {
                Text(NSLocalizedString("sheet.editHabit.field.emoji", comment: "Edit habit field label: Emoji"))
            }

            Section {
                TextField("", text: $name)
            } header: {
                Text(NSLocalizedString("sheet.editHabit.field.name", comment: "Edit habit field label: Name"))
            }

            Section {
                TextField("", text: $unit)
            } header: {
                Text(NSLocalizedString("sheet.editHabit.field.measure", comment: "Edit habit field label: Measure"))
            }

            Section {
                TextField("", text: $goalText)
                    .keyboardType(.numberPad)
            } header: {
                Text(NSLocalizedString("sheet.editHabit.field.target", comment: "Edit habit field label: Target"))
            }

            Section {
                TextField("", text: $stepText)
                    .keyboardType(.numberPad)
            } header: {
                Text(NSLocalizedString("sheet.editHabit.field.logStep", comment: "Edit habit field label: Log step"))
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(NSLocalizedString("action.save", comment: "Save button title")) {
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

private struct AddHabitSheetView: View {
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var unit: String = ""
    @State private var goalText: String = ""
    @State private var stepText: String = ""
    @State private var emoji: String = ""

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
                "sheet.addHabit.limitReached.fmt",
                comment: "Shown when the user reaches the max number of habits. Uses one %d placeholder."
            ),
            HabitsStore.maxHabits
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("sheet.addHabit.section.emoji.title", comment: "Add habit section title: emoji")) {
                    TextField(NSLocalizedString("sheet.addHabit.section.emoji.placeholder", comment: "Add habit emoji placeholder"), text: $emoji)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section(NSLocalizedString("sheet.addHabit.section.name.title", comment: "Add habit section title: name")) {
                    TextField(NSLocalizedString("sheet.addHabit.section.name.placeholder", comment: "Add habit name placeholder"), text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section(NSLocalizedString("sheet.addHabit.section.unit.title", comment: "Add habit section title: measure")) {
                    TextField(NSLocalizedString("sheet.addHabit.section.unit.placeholder", comment: "Add habit measure placeholder"), text: $unit)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section(NSLocalizedString("sheet.addHabit.section.goal.title", comment: "Add habit section title: target")) {
                    TextField(NSLocalizedString("sheet.addHabit.section.goal.placeholder", comment: "Add habit target placeholder"), text: $goalText)
                        .keyboardType(.numberPad)
                }

                Section(NSLocalizedString("sheet.addHabit.section.step.title", comment: "Add habit section title: log step")) {
                    TextField(NSLocalizedString("sheet.addHabit.section.step.placeholder", comment: "Add habit log step placeholder"), text: $stepText)
                        .keyboardType(.numberPad)
                }

                if !canAddMore {
                    Text(limitReachedText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(NSLocalizedString("sheet.addHabit.title", comment: "Add Habit navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("action.cancel", comment: "Cancel button title")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("action.save", comment: "Save button title")) {
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
                }
            }
        }
    }
}

#Preview {
    EditHabitSheetView()
        .environmentObject(HabitsStore())
}
