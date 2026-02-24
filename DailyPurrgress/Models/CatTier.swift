// CatTier.swift ⌘ @jonathaxs

import Foundation

enum CatTier: Int, CaseIterable, Identifiable {
    case low
    case medium
    case high
    case complete

    var id: Int { rawValue }

    // MARK: - Visual Identity

    var emoji: String {
        let defaults = UserDefaults.standard

        let key: String
        let defaultKey: String

        switch self {
        case .low:
            key = "DailyPurrgress.catTier.emoji.low"
            defaultKey = "catTier.low.emoji"
        case .medium:
            key = "DailyPurrgress.catTier.emoji.medium"
            defaultKey = "catTier.medium.emoji"
        case .high:
            key = "DailyPurrgress.catTier.emoji.high"
            defaultKey = "catTier.high.emoji"
        case .complete:
            key = "DailyPurrgress.catTier.emoji.complete"
            defaultKey = "catTier.complete.emoji"
        }

        let override = defaults.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if override.isEmpty == false {
            return override
        }

        return NSLocalizedString(defaultKey, comment: "")
    }

    // MARK: - Copy

    var title: String {
        let defaults = UserDefaults.standard

        let key: String
        let defaultKey: String

        switch self {
        case .low:
            key = "DailyPurrgress.catTier.title.low"
            defaultKey = "catTier.low.title"
        case .medium:
            key = "DailyPurrgress.catTier.title.medium"
            defaultKey = "catTier.medium.title"
        case .high:
            key = "DailyPurrgress.catTier.title.high"
            defaultKey = "catTier.high.title"
        case .complete:
            key = "DailyPurrgress.catTier.title.complete"
            defaultKey = "catTier.complete.title"
        }

        let override = defaults.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if override.isEmpty == false {
            return override
        }

        return NSLocalizedString(defaultKey, comment: "")
    }

    var subtitle: String {
        let defaults = UserDefaults.standard

        let key: String
        let defaultKey: String

        switch self {
        case .low:
            key = "DailyPurrgress.catTier.subtitle.low"
            defaultKey = "catTier.low.subtitle"
        case .medium:
            key = "DailyPurrgress.catTier.subtitle.medium"
            defaultKey = "catTier.medium.subtitle"
        case .high:
            key = "DailyPurrgress.catTier.subtitle.high"
            defaultKey = "catTier.high.subtitle"
        case .complete:
            key = "DailyPurrgress.catTier.subtitle.complete"
            defaultKey = "catTier.complete.subtitle"
        }

        let override = defaults.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if override.isEmpty == false {
            return override
        }

        return NSLocalizedString(defaultKey, comment: "")
    }

    // MARK: - Progress Rules

    /// Creates a CatTier based on a progress value between 0.0 and 1.0
    static func from(progress: Double) -> CatTier {
        let clampedProgress = min(max(progress, 0), 1)

        switch clampedProgress {
        case ..<0.30:
            return .low
        case ..<0.60:
            return .medium
        case ..<1.00:
            return .high
        default:
            return .complete
        }
    }
}
