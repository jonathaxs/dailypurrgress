// Habit.swift ⌘ @jonathaxs


import Foundation

struct Habit: Identifiable, Codable, Equatable {
    // MARK: - Identity

    let id: UUID

    // MARK: - Content

    var name: String
    var unit: String

    // MARK: - Targets

    var goal: Int
    var step: Int

    // MARK: - Progress

    var current: Int

    // MARK: - Rules

    /// Built-in habits (like Water) should not be deletable.
    var isProtected: Bool

    // MARK: - Init

    init(
        id: UUID = UUID(),
        name: String,
        unit: String,
        goal: Int,
        step: Int,
        current: Int = 0,
        isProtected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.unit = unit
        self.goal = max(goal, 0)
        self.step = max(step, 0)
        self.current = max(current, 0)
        self.isProtected = isProtected

        clampProgress()
    }

    // MARK: - Derived

    var isComplete: Bool {
        guard goal > 0 else { return false }
        return current >= goal
    }

    var remaining: Int {
        max(goal - current, 0)
    }

    /// Progress from 0.0 to 1.0 (returns 0 when goal is 0).
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1)
    }

    // MARK: - Mutations

    mutating func logStep() {
        guard step > 0 else { return }
        current = min(current + step, goal)
    }

    mutating func reset() {
        current = 0
    }

    // MARK: - Helpers

    private mutating func clampProgress() {
        if goal < 0 { goal = 0 }
        if step < 0 { step = 0 }
        if current < 0 { current = 0 }

        if goal > 0 {
            current = min(current, goal)
        }

        if goal > 0 {
            step = min(step, goal)
        }
    }
}

// MARK: - Defaults

extension Habit {
    static func waterDefault() -> Habit {
        Habit(
            name: "Water",
            unit: "ml",
            goal: 2000,
            step: 250,
            current: 0,
            isProtected: true
        )
    }
}
