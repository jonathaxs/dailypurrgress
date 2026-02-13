//  ManageHabitsSheetView.swift ⌘ @jonathaxs


import SwiftUI

struct ManageHabitsSheetView: View {
    @EnvironmentObject private var habitsStore: HabitsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(habitsStore.habits) { habit in
                        row(for: habit)
                    }
                } header: {
                    Text("Habits")
                } footer: {
                    Text("Water is built-in and can't be deleted.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Manage Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Row

private extension ManageHabitsSheetView {
    @ViewBuilder
    func row(for habit: Habit) -> some View {
        HStack(spacing: 12) {
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
            } else {
                Button {
                    habitsStore.deleteHabit(id: habit.id)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .tint(.red)
                .accessibilityLabel("Delete")
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ManageHabitsSheetView()
        .environmentObject(HabitsStore())
}
