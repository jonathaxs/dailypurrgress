//  DailyPurrgressApp.swift ⌘ @jonathaxs

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
