// HabitStore.swift ⌘ @jonathaxs

import Foundation
import Combine

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

    var waterHabitID: UUID? {
        habits.first(where: { $0.isProtected })?.id
    }

    func habit(id: UUID) -> Habit? {
        habits.first(where: { $0.id == id })
    }

    private func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func isReadName(_ name: String) -> Bool {
        normalizedName(name) == "read"
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

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        if isReadName(trimmedName) {
            didDeleteRead = false
        }

        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmoji.isEmpty else { return false }

        let trimmedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUnit.isEmpty else { return false }

        guard goal > 0, step > 0, step <= goal else { return false }

        let newHabit = Habit(
            name: trimmedName,
            emoji: trimmedEmoji,
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

    func logStep(for id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }

        var updated = habits
        updated[index].logStep()
        habits = updated

        saveNow()
    }

    func resetHabit(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }

        var updated = habits
        updated[index].reset()
        habits = updated

        saveNow()
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

    func setCurrent(_ newValue: Int, for id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }

        let goal = max(habits[index].goal, 0)
        let step = max(habits[index].step, 1)

        let clamped = min(max(newValue, 0), goal)
        let snapped = (goal > 0) ? (Int((Double(clamped) / Double(step)).rounded()) * step) : 0

        var updated = habits
        updated[index].current = min(max(snapped, 0), goal)
        habits = updated

        scheduleSave()
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

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)

        if isReadName(trimmedName) {
            didDeleteRead = false
        }

        guard !trimmedName.isEmpty,
              !trimmedEmoji.isEmpty,
              !trimmedUnit.isEmpty,
              goal > 0,
              step > 0,
              step <= goal
        else { return false }

        var updated = habits

        var habit = updated[index]
        habit.name = trimmedName
        habit.emoji = String(trimmedEmoji.prefix(1))
        habit.unit = trimmedUnit
        habit.goal = goal
        habit.step = step

        // Clamp current to new goal and align to step
        let clampedCurrent = min(max(habit.current, 0), goal)
        let snapped = (goal > 0)
            ? (Int((Double(clampedCurrent) / Double(step)).rounded()) * step)
            : 0

        habit.current = min(max(snapped, 0), goal)

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
