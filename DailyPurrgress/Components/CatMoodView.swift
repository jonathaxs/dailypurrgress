//  CatMoodView.swift ⌘ @jonathaxs

import SwiftUI

struct CatMoodView: View {
    let tier: CatTier

    var body: some View {
        VStack(spacing: 10) {
            Text(tier.emoji)
                .font(.system(size: 72))
                .scaleEffect(emojiScale)
                .opacity(emojiOpacity)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.75),
                    value: tier
                )

            Text(tier.title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.2), value: tier)

            Text(tier.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.2), value: tier)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tier.title)
        .accessibilityValue(tier.subtitle)
    }

    // MARK: - Subtle Animations

    private var emojiScale: CGFloat {
        switch tier {
        case .low:
            return 0.95   // slightly calmer, not dramatic
        case .medium:
            return 1.0
        case .high:
            return 1.05
        case .complete:
            return 1.1
        }
    }

    private var emojiOpacity: Double {
        switch tier {
        case .low:
            return 0.85
        default:
            return 1.0
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ForEach(CatTier.allCases) { tier in
            CatMoodView(tier: tier)
        }
    }
    .padding()
}
