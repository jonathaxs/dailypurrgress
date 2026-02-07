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
    
    static func logStep(_ amount: Int) -> String {
        "Log +\(amount) ml"
    }

    static let reset = "Reset"

    // MARK: - Accessibility

    static let progressAccessibilityLabel = "Daily progress"
}
