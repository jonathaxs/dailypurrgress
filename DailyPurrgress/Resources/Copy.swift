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
    
    static func remaining(_ amount: Int) -> String {
        "\(amount) ml to go"
    }

    static func progressLine(current: Int, goal: Int) -> String {
        "\(current) / \(goal) ml"
    }
    
    static func logStep(_ amount: Int) -> String {
        "Log +\(amount) ml"
    }

    static let reset = "Reset"

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

    static let logWaterAccessibilityLabel = "Log water"
    static let logWaterAccessibilityHint = "Adds water toward your daily goal"

    static let resetTodayAccessibilityLabel = "Reset today"
    static let resetTodayAccessibilityHint = "Clears your progress for today"
}
