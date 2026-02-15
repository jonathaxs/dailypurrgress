//  Copy.swift ⌘ @jonathaxs

import Foundation

struct Copy {

    // MARK: - Opening

    static let opening = """
    Daily habits don’t have to be loud.
    Sometimes, they just purr.
    """

    // MARK: - Actions
    
    static let goalReached = "Goal reached for today."
    
    static func remaining(_ amount: Int, unit: String) -> String {
        "\(amount) \(unit) to go"
    }

    /// Backward-compatible (defaults to ml)
    static func remaining(_ amount: Int) -> String {
        remaining(amount, unit: "ml")
    }

    static func progressLine(current: Int, goal: Int, unit: String) -> String {
        "\(current) / \(goal) \(unit)"
    }

    /// Backward-compatible (defaults to ml)
    static func progressLine(current: Int, goal: Int) -> String {
        progressLine(current: current, goal: goal, unit: "ml")
    }

    static func logStep(_ amount: Int, unit: String) -> String {
        "Log +\(amount) \(unit)"
    }

    /// Backward-compatible (defaults to ml)
    static func logStep(_ amount: Int) -> String {
        logStep(amount, unit: "ml")
    }

    static let reset = "Reset"
    static let cancel = "Cancel"

    static func resetConfirmationTitle(for habitName: String) -> String {
        "Reset \(habitName)?"
    }

    static func resetConfirmationMessage(for habitName: String) -> String {
        "This will clear your \(habitName) progress for today."
    }

    // MARK: - Accessibility

    static let progressAccessibilityLabel = "Daily progress"
    static let progressAccessibilityHint = "Shows your progress toward the daily goal"

    static let remainingAccessibilityLabel = "Remaining"
    static let remainingAccessibilityHint = "Left to reach your daily goal"

    static func percentCompletedValue(_ percent: Int) -> String {
        "\(percent) percent completed"
    }

    static func millilitersValue(_ amount: Int) -> String {
        "\(amount) milliliters"
    }

    static func unitValue(_ amount: Int, unit: String) -> String {
        "\(amount) \(unit)"
    }

    static func logAccessibilityLabel(for habitName: String) -> String {
        "Log \(habitName)"
    }

    static func logAccessibilityHint(for habitName: String) -> String {
        "Adds progress to your \(habitName) goal"
    }

    static let resetTodayAccessibilityLabel = "Reset today"
    static let resetTodayAccessibilityHint = "Clears your progress for today"
}
