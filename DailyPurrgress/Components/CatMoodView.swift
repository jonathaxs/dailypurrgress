//  CatMoodView.swift ⌘
//  Created by @jonathaxs
//  Swift Student Challenge 2026

import SwiftUI

struct CatMoodView: View {
    let tier: CatTier
    let wiggleTrigger: Int

    // Forces SwiftUI to re-render when CatTier overrides are saved.
    @AppStorage("DailyPurrgress.catTier.refreshTick") private var refreshTick: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var wiggleAngle: Double = 0
    @State private var wiggleScale: CGFloat = 1.0

    init(tier: CatTier, wiggleTrigger: Int = 0) {
        self.tier = tier
        self.wiggleTrigger = wiggleTrigger
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(tier.emoji)
                .font(.system(size: 72))
                .scaleEffect(emojiScale * wiggleScale)
                .rotationEffect(.degrees(wiggleAngle))
                .opacity(emojiOpacity)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.75),
                    value: refreshTick
                )
                .onChange(of: wiggleTrigger) {
                    triggerWiggle()
                }

            Text(tier.title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: refreshTick)

            Text(tier.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: refreshTick)
        }
        .padding(.vertical, 8)
        // When the refresh tick changes, rebuild this view so `tier.emoji/title/subtitle`
        // re-evaluate against updated UserDefaults.
        .id("catMood-\(tier.id)-\(refreshTick)")
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

    // MARK: - Wiggle Trigger

    private func triggerWiggle() {
        guard !reduceMotion else {
            // Reduced motion: a tiny, quick pulse instead of shaking.
            wiggleScale = 1.05
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                wiggleScale = 1.0
            }
            return
        }

        // Shake: small rotation back and forth, then return to rest.
        withAnimation(.easeInOut(duration: 0.07).repeatCount(6, autoreverses: true)) {
            wiggleAngle = 8
            wiggleScale = 1.03
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            wiggleAngle = 0
            wiggleScale = 1.0
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ForEach(CatTier.allCases) { tier in
            CatMoodView(tier: tier, wiggleTrigger: 0)
        }
    }
    .padding()
}
