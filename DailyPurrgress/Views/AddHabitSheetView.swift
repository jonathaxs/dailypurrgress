//  AddHabitSheetView.swift ⌘ @jonathaxs


import SwiftUI

struct AddHabitSheetView: View {
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var unit: String = "ml"
    @State private var goalText: String = "2000"
    @State private var stepText: String = "250"

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

    private var isValid: Bool {
        guard canAddMore else { return false }
        guard !trimmedName.isEmpty else { return false }
        guard !trimmedUnit.isEmpty else { return false }
        guard goal > 0, step > 0, step <= goal else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    TextField("Unit", text: $unit)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Targets") {
                    TextField("Daily goal", text: $goalText)
                        .keyboardType(.numberPad)

                    TextField("Log step", text: $stepText)
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
