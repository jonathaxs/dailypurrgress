//  DailyPurrgressApp.swift ⌘
//  Swift Student Challenge 2026

//  Created by @jonathaxs.
//  Mail: jonathasmrt@me.com

import SwiftUI
import CoreHaptics

@main
struct DailyPurrgressApp: App {
    @StateObject private var habitsStore = HabitsStore()

    init() {
        HapticsWarmup.shared.prepare()
    }
    var body: some Scene {
        WindowGroup {
            TodayMiniView()
                .environmentObject(habitsStore)
        }
    }
}
