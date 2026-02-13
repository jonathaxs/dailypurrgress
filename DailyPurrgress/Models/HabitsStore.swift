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
        guard habits[index].isProtected == false else { return }

        habits.remove(at: index)
        ensureWaterDefaultExists()
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

    // MARK: - Persistence

    private func load() {
        defer {
            ensureWaterDefaultExists()
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

    private func ensureWaterDefaultExists() {
        if habits.contains(where: { $0.isProtected }) { return }
        habits.insert(.waterDefault(), at: 0)
    }
}
