//  MiniProgressModel.swift ⌘ @jonathaxs

import Foundation

struct MiniProgressModel {
    // MARK: - Storage

    private enum Storage {
        static let currentMLKey = "DailyPurrgress.currentML"
    }

    // MARK: - Configuration

    let dailyGoalML: Int = 2000
    let stepML: Int = 250

    // MARK: - State

    private(set) var currentML: Int = 0

    init() {
        let stored = UserDefaults.standard.integer(forKey: Storage.currentMLKey)
        currentML = min(max(stored, 0), dailyGoalML)
    }

    private func saveCurrentML() {
        UserDefaults.standard.set(currentML, forKey: Storage.currentMLKey)
    }

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
    
    var remainingML: Int {
        max(dailyGoalML - currentML, 0)
    }

    // MARK: - Intents

    mutating func addStep() {
        let next = currentML + stepML
        currentML = min(next, dailyGoalML)
        saveCurrentML()
    }

    mutating func reset() {
        currentML = 0
        saveCurrentML()
    }
}
