//  HabitsStore.swift ⌘
//  Created by @jonathaxs
//  Swift Student Challenge 2026

import Foundation
import Combine
import SwiftUI

final class HabitsStore: ObservableObject {
    // MARK: - Limits

    static let maxHabits: Int = 5

    // MARK: - Storage

    private enum Storage {
        static let habitsKey = "DailyPurrgress.habits"
        static let legacyCurrentMLKey = "DailyPurrgress.currentML"
        static let didDeleteReadKey = "DailyPurrgress.didDeleteRead"
    }

    // MARK: - Save Scheduling

    private let saveSubject = PassthroughSubject<Void, Never>()
    private var saveCancellable: AnyCancellable?

    // MARK: - State

    @Published private(set) var habits: [Habit]

    // MARK: - Init

    init() {
        self.habits = []
        load()

        saveCancellable = saveSubject
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.saveNow()
            }
    }

    // MARK: - Queries

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizedName(_ name: String) -> String {
        trimmed(name).lowercased()
    }

    private func normalizedEmoji(_ emoji: String) -> String {
        String(trimmed(emoji).prefix(1))
    }

    private func isReadName(_ name: String) -> Bool {
        normalizedName(name) == "read"
    }

    var waterHabitID: UUID? {
        habits.first(where: { $0.isProtected })?.id
    }

    func habit(id: UUID) -> Habit? {
        habits.first(where: { $0.id == id })
    }

    private var didDeleteRead: Bool {
        get { UserDefaults.standard.bool(forKey: Storage.didDeleteReadKey) }
        set { UserDefaults.standard.set(newValue, forKey: Storage.didDeleteReadKey) }
    }

    // MARK: - Actions

    @discardableResult
    func addHabit(
        name: String,
        emoji: String,
        unit: String,
        goal: Int,
        step: Int
    ) -> Bool {
        guard habits.count < Self.maxHabits else { return false }

        let trimmedName = trimmed(name)
        guard !trimmedName.isEmpty else { return false }

        let candidateName = normalizedName(trimmedName)
        guard habits.contains(where: { normalizedName($0.name) == candidateName }) == false else { return false }

        if isReadName(trimmedName) {
            didDeleteRead = false
        }

        let candidateEmoji = normalizedEmoji(emoji)
        guard candidateEmoji.isEmpty == false else { return false }
        guard habits.contains(where: { normalizedEmoji($0.emoji) == candidateEmoji }) == false else { return false }

        let trimmedUnit = trimmed(unit)
        guard !trimmedUnit.isEmpty else { return false }

        guard goal > 0, step > 0, step <= goal else { return false }

        let newHabit = Habit(
            name: trimmedName,
            emoji: candidateEmoji,
            unit: trimmedUnit,
            goal: goal,
            step: step,
            current: 0,
            isProtected: false
        )

        habits.append(newHabit)
        saveNow()
        return true
    }

    func deleteHabit(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        let habit = habits[index]
        guard habit.isProtected == false else { return }

        if isReadName(habit.name) {
            didDeleteRead = true
        }

        habits.remove(at: index)
        ensureDefaultHabitsExist()
        saveNow()
    }

    /// Reorders habits inside the array and persists the new order.
    func moveHabits(from offsets: IndexSet, to destination: Int) {
        var updated = habits
        updated.move(fromOffsets: offsets, toOffset: destination)
        habits = updated

        saveNow()
    }

    private func mutateHabit(id: UUID, _ mutation: (inout Habit) -> Void, saveImmediately: Bool) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }

        var updated = habits
        mutation(&updated[index])
        habits = updated

        if saveImmediately {
            saveNow()
        } else {
            scheduleSave()
        }
    }

    func logStep(for id: UUID) {
        mutateHabit(id: id, { $0.logStep() }, saveImmediately: true)
    }

    func undoStep(for id: UUID) {
        mutateHabit(id: id, { $0.undoStep() }, saveImmediately: true)
    }

    func resetHabit(id: UUID) {
        mutateHabit(id: id, { $0.reset() }, saveImmediately: true)
    }

    func resetAll() {
        guard habits.isEmpty == false else { return }

        var updated = habits
        for index in updated.indices {
            updated[index].current = 0
        }
        habits = updated

        saveNow()
    }

    private func snappedValue(_ value: Int, goal: Int, step: Int) -> Int {
        let safeGoal = max(goal, 0)
        let safeStep = max(step, 1)

        let clamped = min(max(value, 0), safeGoal)
        let snapped = (safeGoal > 0)
            ? (Int((Double(clamped) / Double(safeStep)).rounded()) * safeStep)
            : 0

        return min(max(snapped, 0), safeGoal)
    }

    func setCurrent(_ newValue: Int, for id: UUID) {
        mutateHabit(id: id, { habit in
            habit.current = snappedValue(newValue, goal: habit.goal, step: habit.step)
        }, saveImmediately: false)
    }

    @discardableResult
    func updateHabit(
        id: UUID,
        name: String,
        emoji: String,
        unit: String,
        goal: Int,
        step: Int
    ) -> Bool {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return false }

        var updated = habits
        var habit = updated[index]

        let trimmedName = trimmed(name)
        let trimmedEmoji = trimmed(emoji)
        let trimmedUnit = trimmed(unit)

        // Water (protected) must keep its identity.
        // We still allow editing the other fields.
        if habit.isProtected == false {
            if isReadName(trimmedName) {
                didDeleteRead = false
            }

            guard !trimmedName.isEmpty,
                  !trimmedEmoji.isEmpty
            else { return false }

            habit.name = trimmedName
            habit.emoji = String(trimmedEmoji.prefix(1))
        }

        guard !trimmedUnit.isEmpty,
              goal > 0,
              step > 0,
              step <= goal
        else { return false }

        habit.unit = trimmedUnit
        habit.goal = goal
        habit.step = step

        // Clamp current to new goal and align to step.
        habit.current = snappedValue(habit.current, goal: goal, step: step)

        updated[index] = habit
        habits = updated

        saveNow()
        return true
    }

    // MARK: - Persistence

    private func load() {
        defer {
            ensureDefaultHabitsExist()
        }

        guard let data = UserDefaults.standard.data(forKey: Storage.habitsKey) else {
            if UserDefaults.standard.object(forKey: Storage.legacyCurrentMLKey) != nil {
                let stored = UserDefaults.standard.integer(forKey: Storage.legacyCurrentMLKey)

                var water = Habit.waterDefault()
                water.current = min(max(stored, 0), water.goal)

                habits = [water]

                // Migrate once, then clear legacy key.
                UserDefaults.standard.removeObject(forKey: Storage.legacyCurrentMLKey)
                saveNow()
                return
            }

            habits = []
            return
        }

        do {
            let decoded = try JSONDecoder().decode([Habit].self, from: data)
            habits = Array(decoded.prefix(Self.maxHabits))
        } catch {
            habits = []
        }
    }

    private func scheduleSave() {
        saveSubject.send(())
    }

    private func saveNow() {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: Storage.habitsKey)
        } catch {
            // Intentionally ignore save failures.
        }
    }

    private func ensureDefaultHabitsExist() {
        // Water (protected)
        if habits.contains(where: { $0.isProtected }) == false {
            habits.insert(.waterDefault(), at: 0)
        }

        // Read (deletable)
        let hasRead = habits.contains { isReadName($0.name) }
        if hasRead {
            return
        }

        // If the user deleted Read, do not auto-recreate it.
        guard didDeleteRead == false else { return }
        guard habits.count < Self.maxHabits else { return }

        let read = Habit(
            name: "Read",
            emoji: "📘",
            unit: "pages",
            goal: 20,
            step: 2,
            current: 0,
            isProtected: false
        )

        // Prefer to keep Read right after Water.
        if let waterIndex = habits.firstIndex(where: { $0.isProtected }) {
            let insertIndex = min(waterIndex + 1, habits.count)
            habits.insert(read, at: insertIndex)
        } else {
            habits.insert(read, at: 0)
        }
    }
}
