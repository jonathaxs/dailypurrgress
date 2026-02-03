//  MiniProgressModel.swift ⌘ @jonathaxs

import Foundation

struct MiniProgressModel {
    // MARK: - Configuration

    let dailyGoalML: Int = 2000
    let stepML: Int = 250

    // MARK: - State

    private(set) var currentML: Int = 0

    // MARK: - Derived Values

    var progress: Double {
        guard dailyGoalML > 0 else { return 0 }
        return min(Double(currentML) / Double(dailyGoalML), 1.0)
    }

    var tier: CatTier {
        CatTier.from(progress: progress)
    }

    var isComplete: Bool {
        currentML >= dailyGoalML
    }

    // MARK: - Intents

    mutating func addStep() {
        let next = currentML + stepML
        currentML = min(next, dailyGoalML)
    }

    mutating func reset() {
        currentML = 0
    }
}
