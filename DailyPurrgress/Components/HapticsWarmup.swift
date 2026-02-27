//  HapticsWarmup.swift⌘
//  Created by @jonathaxs
//  Swift Student Challenge 2026

//  Prepares the CoreHaptics engine early to avoid first-use latency
//  when triggering haptic feedback (cold start delay).

import Foundation
import CoreHaptics

/// Warms up the haptics engine at app launch so the first
/// interaction that uses `.sensoryFeedback` does not lag.
final class HapticsWarmup {
    static let shared = HapticsWarmup()

    private var engine: CHHapticEngine?
    private var didPrepare = false

    private init() {}

    /// Call once during app startup.
    func prepare() {
        guard !didPrepare else { return }
        didPrepare = true

        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        do {
            let engine = try CHHapticEngine()
            self.engine = engine

            // Starting the engine is usually enough to eliminate
            // the first interaction hitch.
            try engine.start()
        } catch {
            // Fail silently — haptics are optional.
        }
    }
}
