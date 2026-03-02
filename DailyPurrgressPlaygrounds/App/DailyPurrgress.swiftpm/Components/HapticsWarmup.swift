//  HapticsWarmup.swift⌘
//  Swift Student Challenge 2026
//  Created by @jonathaxs

import Foundation
import CoreHaptics

/// Warms up the haptics engine at app launch so the first
@MainActor
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
            // Fail silently haptics are optional..
        }
    }
}
