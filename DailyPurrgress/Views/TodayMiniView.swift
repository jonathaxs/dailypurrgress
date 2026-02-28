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
    @GestureState private var isRingPressed: Bool = false

    @AppStorage("DailyPurrgress.inspirationalMessageOverride")
    private var inspirationalMessageOverride: String = ""

    // Increment to trigger a subtle haptic on log actions.
    @State private var logHapticTick: Int = 0

    // Increment to trigger a double haptic when a reset is confirmed.
    @State private var resetHapticTick: Int = 0

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

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                adaptiveContent(for: proxy.size)
                    .padding()
            }
            .sensoryFeedback(.impact, trigger: logHapticTick)
            .sensoryFeedback(.warning, trigger: resetHapticTick)
            .sheet(isPresented: $isPresentingEditHabit) {
                EditHabitSheetView()
                    .environmentObject(habitsStore)
            }
            .sheet(isPresented: $isPresentingInspirationalMessageEditor) {
                InspirationalMessageSheetView(defaultMessage: inspirationalMessageDefault)
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
    // MARK: - Constants

    enum UI {
        static let contentMaxWidth: CGFloat = 330
        static let heroColumnWidth: CGFloat = 360
        static let heroAreaMinHeight: CGFloat = 260
        static let heroAreaMaxHeight: CGFloat = 340
        static let heroAreaRatio: CGFloat = 0.36
        static let portraitSectionSpacing: CGFloat = 15
        static let heroInnerSpacing: CGFloat = 12
        static let heroSectionSpacing: CGFloat = 8
        static let heroRowSpacing: CGFloat = 18
        static let footerSpacing: CGFloat = 12
        static let ringSize: CGFloat = 108
        static let ringLineWidth: CGFloat = 12
        static let messageMaxWidth: CGFloat = 320
        static let habitsBottomPadding: CGFloat = 16
        static let habitsTopPadding: CGFloat = 12
        static let resetDoubleHapticDelayNanos: UInt64 = 120_000_000
        static let resetAnimationDuration: TimeInterval = 0.20
        static let logAnimationResponse: TimeInterval = 0.35
        static let logAnimationDamping: Double = 0.75
        static let undoAnimationResponse: TimeInterval = 0.30
        static let undoAnimationDamping: Double = 0.78
        static let sliderSetAnimationDuration: TimeInterval = 0.12
        static let pressScaleAmount: Double = 1.20
        static let wideThreshold: CGFloat = 700
        static let wideHStackSpacing: CGFloat = 24
        static let portraitHabitsGap: CGFloat = 15
    }

    // MARK: - Copy

    private var inspirationalMessageDefault: String {
        NSLocalizedString(
            "todayMini.inspirationalMessage.default",
            comment: "Inspirational message default copy"
        )
    }

    private var inspirationalMessageText: String {
        let trimmedOverride = inspirationalMessageOverride.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedOverride.isEmpty ? inspirationalMessageDefault : trimmedOverride
    }

    // MARK: - Layout

    private var contentMaxWidth: CGFloat { UI.contentMaxWidth }

    func adaptiveContent(for size: CGSize) -> some View {
        let isLandscape = size.width > size.height
        let isWide = isLandscape && size.width >= UI.wideThreshold

        return Group {
            if isWide {
                wideContent(for: size)
            } else {
                portraitContent(for: size)
            }
        }
    }

    func portraitContent(for size: CGSize) -> some View {
        let heroAreaHeight = min(max(UI.heroAreaMinHeight, size.height * UI.heroAreaRatio), UI.heroAreaMaxHeight)

        return GeometryReader { outerProxy in
            let maxHabitsHeight = max(0, outerProxy.size.height - heroAreaHeight - UI.portraitHabitsGap)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: UI.portraitSectionSpacing) {
                    VStack(spacing: UI.heroInnerSpacing) {
                        Spacer(minLength: 0)

                        heroSection
                            .frame(maxWidth: .infinity, alignment: .center)

                        footerControls

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: heroAreaHeight)

                    // Use `ViewThatFits` so we only introduce scrolling when we actually need it.
                    // This keeps the whole layout centered in portrait when there are few habits.
                    ViewThatFits(in: .vertical) {
                        // No scroll when everything fits.
                        habitsContent

                        // Scroll only when content doesn't fit.
                        ScrollView {
                            habitsContent
                        }
                        .frame(maxHeight: maxHabitsHeight)
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func wideContent(for size: CGSize) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            HStack(alignment: .top, spacing: UI.wideHStackSpacing) {
                VStack(alignment: .center, spacing: UI.heroInnerSpacing) {
                    Spacer(minLength: 0)

                    inspirationalMessage
                        .frame(maxWidth: .infinity, alignment: .center)

                    heroRow

                    footerControls

                    Spacer(minLength: 0)
                }
                .frame(width: UI.heroColumnWidth)

                GeometryReader { habitsProxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)

                            habitsContent

                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: habitsProxy.size.height)
                    }
                }
                .frame(width: contentMaxWidth)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    var heroSection: some View {
        VStack(alignment: .leading, spacing: UI.heroSectionSpacing) {
            inspirationalMessage
                .frame(maxWidth: .infinity, alignment: .center)

            heroRow
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    var heroRow: some View {
        HStack(spacing: UI.heroRowSpacing) {
            Button {
                isPresentingCatTierEditor = true
            } label: {
                CatMoodView(tier: overallTier)
            }
            .buttonStyle(.plain)
            // Lock this copy to the standard Dynamic Type size so Accessibility text sizes
            .dynamicTypeSize(.medium)
            .pressScaleEffect()
            .accessibilityLabel(Text(NSLocalizedString("a11y.catMood.label", comment: "")))
            .accessibilityHint(Text(NSLocalizedString("a11y.catMood.hint", comment: "")))

            Button {
                // Tap still works (no-op). The highlight is driven by press state.
            } label: {
                ProgressRingView(
                    progress: overallProgress,
                    size: UI.ringSize,
                    lineWidth: UI.ringLineWidth,
                    overrideRingColor: isRingPressed ? .purple : nil
                )
            }
            .buttonStyle(.plain)
            .scaleEffect(isRingPressed ? UI.pressScaleAmount : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.50), value: isRingPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isRingPressed) { _, state, _ in
                        state = true
                    }
            )
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
                        logHapticTick += 1
                        withAnimation(.spring(response: UI.logAnimationResponse, dampingFraction: UI.logAnimationDamping)) {
                            habitsStore.logStep(for: habit.id)
                        }
                    },
                    onUndoStep: {
                        logHapticTick += 1
                        withAnimation(.spring(response: UI.undoAnimationResponse, dampingFraction: UI.undoAnimationDamping)) {
                            habitsStore.undoStep(for: habit.id)
                        }
                    },
                    onSetCurrent: { newValue in
                        withAnimation(.easeInOut(duration: UI.sliderSetAnimationDuration)) {
                            habitsStore.setCurrent(newValue, for: habit.id)
                        }
                    }
                )
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    var habitsContent: some View {
        habitsSection
            .padding(.top, UI.habitsTopPadding)
            .padding(.bottom, UI.habitsBottomPadding)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var footerControls: some View {
        HStack(spacing: UI.footerSpacing) {
            Button(NSLocalizedString("common.action.editHabits", comment: "")) {
                isPresentingEditHabit = true
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .pressScaleEffect()

            Button(NSLocalizedString("common.action.resetAll", comment: "")) {
                isConfirmingResetAll = true
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .tint(.red)
            .pressScaleEffect()
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
                Task { @MainActor in
                    resetHapticTick += 1
                    try? await Task.sleep(nanoseconds: UI.resetDoubleHapticDelayNanos)
                    resetHapticTick += 1
                }

                withAnimation(.easeInOut(duration: UI.resetAnimationDuration)) {
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
                .font(.body)
                // Lock this copy to the standard Dynamic Type size so Accessibility text sizes
                .dynamicTypeSize(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: UI.messageMaxWidth)
        }
        .controlSize(.large)
        .pressScaleEffect()
        .accessibilityLabel(Text(NSLocalizedString("a11y.inspirationalMessage.label", comment: "Accessibility label for the inspirational message button")))
        .accessibilityHint(Text(NSLocalizedString("a11y.inspirationalMessage.hint", comment: "Accessibility hint for editing the inspirational message")))
    }
}

// MARK: - Press Scale Effect

private struct PressScaleEffect: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var isPressed: Bool = false

    func body(content: Content) -> some View {
        let scale: CGFloat = reduceMotion ? 1.0 : (isPressed ? TodayMiniView.UI.pressScaleAmount : 1.0)

        content
            .scaleEffect(scale)
            .animation(
                reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.50),
                value: isPressed
            )
            // Track press state without interfering with Button's tap.
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
    }
}

private extension View {
    func pressScaleEffect() -> some View {
        modifier(PressScaleEffect())
    }
}

// MARK: - Preview

#Preview {
    TodayMiniView()
        .environmentObject(HabitsStore())
}
