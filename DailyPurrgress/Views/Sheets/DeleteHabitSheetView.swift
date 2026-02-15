//  DeleteHabitSheetView.swift ⌘ @jonathaxs

import SwiftUI

struct DeleteHabitSheetView: View {
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(habitsStore.habits) { habit in
                        row(for: habit)
                            .deleteDisabled(habit.isProtected)
                    }
                    .onDelete(perform: delete)
                } header: {
                    Text("Habits")
                } footer: {
                    Text("Water is your default habit and can’t be deleted.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Delete Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editMode.isEditing ? "Done" : "Delete") {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Row

private extension DeleteHabitSheetView {
    func delete(at offsets: IndexSet) {
        let habits = habitsStore.habits

        for index in offsets {
            guard habits.indices.contains(index) else { continue }
            let habit = habits[index]
            guard !habit.isProtected else { continue }
            habitsStore.deleteHabit(id: habit.id)
        }
    }

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

            if habit.isProtected {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Built-in")
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DeleteHabitSheetView()
        .environmentObject(HabitsStore())
}
