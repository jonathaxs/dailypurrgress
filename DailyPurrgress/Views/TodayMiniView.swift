//  TodayMiniView.swift ⌘
//  Created by @jonathaxs
//  Swift Student Challenge 2026

import SwiftUI

struct TodayMiniView: View {
    // MARK: - Dependencies
    @EnvironmentObject private var habitsStore: HabitsStore

    // MARK: - UI State
    @State private var isPresentingEditHabit: Bool = false
    @State private var isConfirmingResetAll: Bool = false
    @State private var isPresentingInspirationalMessageEditor: Bool = false
    @State private var isPresentingCatTierEditor: Bool = false
    @State private var isRingPulsing: Bool = false

    @AppStorage("DailyPurrgress.inspirationalMessageOverride")
    private var inspirationalMessageOverride: String = ""

    // Increment to trigger a subtle haptic on log actions.
    @State private var hapticTrigger: Int = 0

    // Increment to trigger a double haptic when a reset is confirmed.
    @State private var resetHapticTrigger: Int = 0

    // MARK: - Derived State
    private var overallProgress: Double {
        let valid = habitsStore.habits.filter { $0.goal > 0 }
        guard valid.isEmpty == false else { return 0 }

        let sum = valid.reduce(0.0) { partial, habit in
            partial + habit.progress
        }

        return min(max(sum / Double(valid.count), 0), 1)
    }

    private var overallTier: CatTier {
        CatTier.from(progress: overallProgress)
    }

    private func triggerRingPulse() {
        isRingPulsing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            isRingPulsing = false
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                adaptiveContent(for: proxy.size)
                    .padding()
            }
            .sensoryFeedback(.impact, trigger: hapticTrigger)
            .sensoryFeedback(.warning, trigger: resetHapticTrigger)
            .sheet(isPresented: $isPresentingEditHabit) {
                EditHabitSheetView()
                    .environmentObject(habitsStore)
            }
            .sheet(isPresented: $isPresentingInspirationalMessageEditor) {
                InspirationalMessageSheetView(
                    defaultMessage: NSLocalizedString(
                        "todayMini.inspirationalMessage.default",
                        comment: "Inspirational Message default"
                    )
                )
            }
            .sheet(isPresented: $isPresentingCatTierEditor) {
                CatTierSheetView()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sections

private extension TodayMiniView {
    private var inspirationalMessageText: String {
        let defaultMessage = NSLocalizedString(
            "todayMini.inspirationalMessage.default",
            comment: "Inspirational Message default"
        )

        let trimmedOverride = inspirationalMessageOverride.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedOverride.isEmpty ? defaultMessage : trimmedOverride
    }

    // MARK: - Layout

    private var contentMaxWidth: CGFloat { 330 }

    func adaptiveContent(for size: CGSize) -> some View {
        // Prefer the stacked (iPhone-like) layout in portrait, even on iPad.
        // Use the split layout only when we truly have a landscape-wide canvas.
        let isLandscape = size.width > size.height
        let isWide = isLandscape && size.width >= 700

        return Group {
            if isWide {
                wideContent(for: size)
            } else {
                portraitContent(for: size)
            }
        }
    }

    // iPhone-like (portrait) layout:
    // Container X centers Container 1 (hero) and Container 2 (habits) as a group.
    // Container 1 centers Container J (message + ring + tier + buttons).
    // Container 2 holds the habits and grows independently (scrolls only when needed).
    func portraitContent(for size: CGSize) -> some View {
        // Container 1 height: keep the hero centered and stable while habits grow.
        // Tuned to feel iPhone-like on iPad portrait too.
        let heroAreaHeight = min(max(260, size.height * 0.36), 340)

        return GeometryReader { outerProxy in
            let maxHabitsHeight = max(0, outerProxy.size.height - heroAreaHeight - 15)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 15) {
                    // Container 1 (hero) — centers Container J inside it.
                    VStack(spacing: 12) {
                        Spacer(minLength: 0)

                        heroSection
                            .frame(maxWidth: .infinity, alignment: .center)

                        footerControls

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: heroAreaHeight)

                    // Container 2 (habits) — grows up to a max height; centers when short.
                    ScrollView {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)

                            habitsSection
                                .padding(.bottom, 16)
                                .frame(maxWidth: .infinity, alignment: .center)

                            Spacer(minLength: 0)
                        }
                    }
                    .frame(maxHeight: maxHabitsHeight)
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // Landscape-wide layout: Container X centers Container 1 (hero column) and Container 2 (habits column).
    func wideContent(for size: CGSize) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            HStack(alignment: .top, spacing: 24) {
                // Container 1 (hero)
                VStack(alignment: .center, spacing: 12) {
                    Spacer(minLength: 0)

                    inspirationalMessage
                        .frame(maxWidth: .infinity, alignment: .center)

                    heroRow

                    footerControls

                    Spacer(minLength: 0)
                }
                .frame(width: 360)

                // Container 2 (habits)
                GeometryReader { habitsProxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)

                            habitsSection
                                .padding(.bottom, 16)
                                .frame(maxWidth: .infinity, alignment: .center)

                            Spacer(minLength: 0)
                        }
                        // Ensures centering when content is shorter than the available height.
                        .frame(minHeight: habitsProxy.size.height)
                    }
                }
                .frame(width: contentMaxWidth)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 0)
        }
        // Container X
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Building Blocks

    var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            inspirationalMessage
                .frame(maxWidth: .infinity, alignment: .center)

            heroRow
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    var heroRow: some View {
        HStack(spacing: 18) {
            Button {
                isPresentingCatTierEditor = true
            } label: {
                CatMoodView(tier: overallTier)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(NSLocalizedString("a11y.catMood.label", comment: "")))
            .accessibilityHint(Text(NSLocalizedString("a11y.catMood.hint", comment: "")))

            Button {
                triggerRingPulse()
            } label: {
                ProgressRingView(
                    progress: overallProgress,
                    size: 108,
                    lineWidth: 12
                )
                .scaleEffect(isRingPulsing ? 1.08 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isRingPulsing)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(NSLocalizedString("a11y.progressRing.label", comment: "")))
            .accessibilityHint(Text(NSLocalizedString("a11y.progressRing.hint", comment: "")))
        }
    }

    var habitsSection: some View {
        VStack(spacing: 8) {
            ForEach(habitsStore.habits) { habit in
                HabitRowView(
                    habit: habit,
                    onLogStep: {
                        // Haptic tick + animated progress update.
                        hapticTrigger += 1
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            habitsStore.logStep(for: habit.id)
                        }
                    },
                    onUndoStep: {
                        hapticTrigger += 1
                        withAnimation(.spring(response: 0.30, dampingFraction: 0.78)) {
                            habitsStore.undoStep(for: habit.id)
                        }
                    },
                    onSetCurrent: { newValue in
                        withAnimation(.easeInOut(duration: 0.12)) {
                            habitsStore.setCurrent(newValue, for: habit.id)
                        }
                    }
                )
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    var footerControls: some View {
        HStack(spacing: 12) {
            Button(NSLocalizedString("common.action.editHabits", comment: "")) {
                isPresentingEditHabit = true
            }
            .buttonStyle(.bordered)

            Button(NSLocalizedString("common.action.resetAll", comment: "")) {
                isConfirmingResetAll = true
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .frame(maxWidth: contentMaxWidth)
        .frame(maxWidth: .infinity, alignment: .center)
        .controlSize(.large)
        .confirmationDialog(
            NSLocalizedString("common.confirm.resetAll.title", comment: ""),
            isPresented: $isConfirmingResetAll,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("common.action.resetAll", comment: ""), role: .destructive) {
                // Double haptic only when the reset actually happens.
                Task { @MainActor in
                    resetHapticTrigger += 1
                    try? await Task.sleep(nanoseconds: 120_000_000)
                    resetHapticTrigger += 1
                }

                // Clear all habits' progress for today.
                withAnimation(.easeInOut(duration: 0.2)) {
                    habitsStore.resetAll()
                }
            }
            Button(NSLocalizedString("common.action.cancel", comment: ""), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("common.confirm.resetAll.message", comment: ""))
        }
    }

    var inspirationalMessage: some View {
        Button {
            isPresentingInspirationalMessageEditor = true
        } label: {
            Text(inspirationalMessageText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 320)
        }
        .controlSize(.large)
        .accessibilityLabel(Text("Inspirational message"))
        .accessibilityHint(Text("Double tap to edit"))
    }
}

// MARK: - Preview

#Preview {
    TodayMiniView()
        .environmentObject(HabitsStore())
}
