//  AddHabitSheetView.swift ⌘ @jonathaxs


import SwiftUI

struct AddHabitSheetView: View {
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

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit emoji") {
                    TextField("example: 💪", text: $emoji)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section("Habit name") {
                    TextField("example: Protein", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("Habit measure") {
                    TextField("example: g", text: $unit)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section("Measure target") {
                    TextField("example: 140", text: $goalText)
                        .keyboardType(.numberPad)
                }
                
                Section("Log step") {
                    TextField("example: 20", text: $stepText)
                        .keyboardType(.numberPad)
                }
                

                if !canAddMore {
                    Text("Limit reached (max \(HabitsStore.maxHabits) habits).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if canAddMore {
                    Text("Tip: Keep it small and simple.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
    AddHabitSheetView()
        .environmentObject(HabitsStore())
}
