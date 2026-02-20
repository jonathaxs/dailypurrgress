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
        switch self {
        case .low:
            return NSLocalizedString("catTier.low.emoji", comment: "")
        case .medium:
            return NSLocalizedString("catTier.medium.emoji", comment: "")
        case .high:
            return NSLocalizedString("catTier.high.emoji", comment: "")
        case .complete:
            return NSLocalizedString("catTier.complete.emoji", comment: "")
        }
    }

    // MARK: - Copy

    var title: String {
        switch self {
        case .low:
            return NSLocalizedString("catTier.low.title", comment: "")
        case .medium:
            return NSLocalizedString("catTier.medium.title", comment: "")
        case .high:
            return NSLocalizedString("catTier.high.title", comment: "")
        case .complete:
            return NSLocalizedString("catTier.complete.title", comment: "")
        }
    }

    var subtitle: String {
        switch self {
        case .low:
            return NSLocalizedString("catTier.low.subtitle", comment: "")
        case .medium:
            return NSLocalizedString("catTier.medium.subtitle", comment: "")
        case .high:
            return NSLocalizedString("catTier.high.subtitle", comment: "")
        case .complete:
            return NSLocalizedString("catTier.complete.subtitle", comment: "")
        }
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
