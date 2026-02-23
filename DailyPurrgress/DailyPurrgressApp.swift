//  DailyPurrgressApp.swift ⌘
//  Created by @jonathaxs.
//  Swift Student Challenge 2026

import SwiftUI
import CoreHaptics

@main
struct DailyPurrgressApp: App {
    @StateObject private var habitsStore = HabitsStore()

    init() {
        // Warm up the haptics engine early to avoid a first-tap delay (cold start).
        HapticsWarmup.shared.prepare()
    }
    var body: some Scene {
        WindowGroup {
            TodayMiniView()
                .environmentObject(habitsStore)
        }
    }
}
