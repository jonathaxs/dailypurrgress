// EditHabitSheetView.swift ⌘ @jonathaxs

import SwiftUI

struct EditHabitSheetView: View {

    // MARK: - Dependencies

    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - UI State

    @State private var editMode: EditMode = .inactive
    @State private var isPresentingAddHabit: Bool = false

    // MARK: - Derived State

    private var canAddMore: Bool {
        habitsStore.habits.count < HabitsStore.maxHabits
    }

    // MARK: - View

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
                    Text(NSLocalizedString("editHabitsSheet.section.title", comment: "Header title for habits list section"))
                } footer: {
                    Text(NSLocalizedString("editHabitsSheet.footer.waterProtected", comment: "Footer note explaining that Water cannot be deleted"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle(NSLocalizedString("editHabitsSheet.title", comment: "Edit habits sheet navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("common.action.back", comment: "Back button title")) {
                        dismiss()
                    }
                    .tint(.primary) // system default: adapts to light/dark for iOS 17
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(NSLocalizedString("common.action.add", comment: "Add button title")) {
                            isPresentingAddHabit = true
                        }
                        .disabled(!canAddMore)
                        .tint(.blue)

                        Button(
                            editMode.isEditing
                            ? NSLocalizedString("common.action.done", comment: "Done button title")
                            : NSLocalizedString("common.action.delete", comment: "Enter delete mode button title")
                        ) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                editMode = editMode.isEditing ? .inactive : .active
                            }
                        }
                        // Visual cue: Done (green) vs Delete (red)
                        .foregroundStyle(editMode.isEditing ? .green : .red)
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

#Preview {
    EditHabitSheetView()
        .environmentObject(HabitsStore())
}
