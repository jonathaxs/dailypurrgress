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
            return NSLocalizedString("tier.low.emoji", comment: "")
        case .medium:
            return NSLocalizedString("tier.medium.emoji", comment: "")
        case .high:
            return NSLocalizedString("tier.high.emoji", comment: "")
        case .complete:
            return NSLocalizedString("tier.complete.emoji", comment: "")
        }
    }

    // MARK: - Copy

    var title: String {
        switch self {
        case .low:
            return NSLocalizedString("tier.low.title", comment: "")
        case .medium:
            return NSLocalizedString("tier.medium.title", comment: "")
        case .high:
            return NSLocalizedString("tier.high.title", comment: "")
        case .complete:
            return NSLocalizedString("tier.complete.title", comment: "")
        }
    }

    var subtitle: String {
        switch self {
        case .low:
            return NSLocalizedString("tier.low.subtitle", comment: "")
        case .medium:
            return NSLocalizedString("tier.medium.subtitle", comment: "")
        case .high:
            return NSLocalizedString("tier.high.subtitle", comment: "")
        case .complete:
            return NSLocalizedString("tier.complete.subtitle", comment: "")
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
