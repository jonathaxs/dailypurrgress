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
            return "🐱"
        case .medium:
            return "😺"
        case .high:
            return "🐈"
        case .complete:
            return "⭐️"
        }
    }

    // MARK: - Copy

    var title: String {
        switch self {
        case .low:
            return "It’s okay to start small."
        case .medium:
            return "Nice and steady."
        case .high:
            return "This feels good."
        case .complete:
            return "Well done."
        }
    }

    var subtitle: String {
        switch self {
        case .low:
            return "Every habit begins somewhere."
        case .medium:
            return "You’re taking care of yourself."
        case .high:
            return "Consistency is quietly building."
        case .complete:
            return "Small habits add up."
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
