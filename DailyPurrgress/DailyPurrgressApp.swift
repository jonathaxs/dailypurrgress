//  DailyPurrgressApp.swift ⌘
//  Created by @jonathaxs.
//  Swift Student Challenge 2026

import SwiftUI

@main
struct DailyPurrgressApp: App {
    @StateObject private var habitsStore = HabitsStore()
    var body: some Scene {
        WindowGroup {
            TodayMiniView()
                .environmentObject(habitsStore)
        }
    }
}
