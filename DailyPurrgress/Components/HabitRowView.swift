//  HabitRowView.swift ⌘
//  Created by @jonathaxs
//  Swift Student Challenge 2026

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onLogStep: () -> Void
    let onUndoStep: () -> Void
    let onSetCurrent: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var undoHapticTick: Int = 0
    @State private var sliderHapticTick: Int = 0

    @State private var isUndoPulsing: Bool = false
    @State private var isLogPulsing: Bool = false

    private func t(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private func tf(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), arguments: args)
    }


    private func pulseUndoButton() {
        guard !reduceMotion else { return }
        isUndoPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            isUndoPulsing = false
        }
    }

    private func pulseLogButton() {
        guard !reduceMotion else { return }
        isLogPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            isLogPulsing = false
        }
    }

    init(
        habit: Habit,
        onLogStep: @escaping () -> Void,
        onUndoStep: @escaping () -> Void,
        onSetCurrent: @escaping (Int) -> Void
    ) {
        self.habit = habit
        self.onLogStep = onLogStep
        self.onUndoStep = onUndoStep
        self.onSetCurrent = onSetCurrent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            slider
            actions
        }
        .padding(14)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.thinMaterial)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(progressTint)
                    .opacity(backgroundWashOpacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(progressTint.opacity(0.25), lineWidth: 1)
        }
        // Expose a summary value while keeping inner controls accessible to VoiceOver.
        .accessibilityElement(children: .contain)
        .accessibilityLabel(habit.name)
        .accessibilityValue(progressAccessibilityValue)
        .sensoryFeedback(.impact, trigger: undoHapticTick)
        .sensoryFeedback(.selection, trigger: sliderHapticTick)
    }
}

// MARK: - Sections

private extension HabitRowView {
    var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(habit.emoji)
                .font(.headline)
                .accessibilityHidden(true)

            Text(habit.name)
                .font(.headline)

            Spacer(minLength: 10)

            Text(progressLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    var slider: some View {
        let safeGoal = max(habit.goal, 0)
        let safeStep = max(habit.step, 1)

        let maxGoal = Double(safeGoal)
        let step = Double(safeStep)

        // Slider outputs Double; snap to habit.step and clamp within [0, goal].
        let binding = Binding<Double>(
            get: { Double(habit.current) },
            set: { newValue in
                guard safeGoal > 0 else { return }

                let rounded = Int((newValue / step).rounded()) * safeStep
                let clamped = min(max(rounded, 0), safeGoal)

                guard clamped != habit.current else { return }
                sliderHapticTick += 1
                onSetCurrent(clamped)
            }
        )

        return Slider(
            value: binding,
            in: 0...maxGoal,
            step: step
        )
        .disabled(safeGoal == 0)
        .accessibilityLabel(t("a11y.habit.slider.label"))
        .accessibilityValue(sliderAccessibilityValue)
        .accessibilityHint(t("a11y.habit.slider.hint"))
    }

    var actions: some View {
        HStack(spacing: 10) {
            Button {
                guard habit.current > 0 else { return }
                undoHapticTick += 1
                pulseUndoButton()
                onUndoStep()
            } label: {
                Text(t("common.action.undo"))
                    .frame(maxWidth: .infinity, minHeight: 25)
            }
            .buttonStyle(.bordered)
            .scaleEffect(isUndoPulsing ? 1.08 : 1.0)
            .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.62), value: isUndoPulsing)
            .disabled(habit.current == 0)
            .accessibilityLabel(t("a11y.habit.undo.label"))
            .accessibilityHint(t("a11y.habit.undo.hint"))

            Button {
                pulseLogButton()
                onLogStep()
            } label: {
                Text(t("common.action.log"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, minHeight: 25)
            }
            .buttonStyle(.borderedProminent)
            .scaleEffect(isLogPulsing ? 1.08 : 1.0)
            .animation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.62), value: isLogPulsing)
            .disabled(habit.isComplete)
            .opacity(habit.isComplete ? 0.6 : 1.0)
            .accessibilityLabel(tf("a11y.habit.log.label.fmt", habit.name))
            .accessibilityHint(tf("a11y.habit.log.hint.fmt", habit.name))
            .accessibilityValue(tf("a11y.unitValue.fmt", habit.step, habit.unit))
        }
    }

    var progressLine: String {
        tf("habit.progressLine.fmt", habit.current, habit.goal, habit.unit)
    }

    var progressAccessibilityValue: String {
        tf("a11y.progressRing.percentCompleted.fmt", Int((habit.progress * 100).rounded()))
    }

    var sliderAccessibilityValue: String {
        tf("a11y.unitValue.fmt", habit.current, habit.unit)
    }

    var clampedProgress: Double {
        min(max(habit.progress, 0), 1)
    }

    // Progress color tiers: <30% red, <60% orange, <100% green, 100%+ blue.
    var progressTint: Color {
        switch clampedProgress {
        case ..<0.30:
            return .red
        case ..<0.60:
            return .orange
        case ..<1.0:
            return .green
        default:
            return .blue
        }
    }

    var backgroundWashOpacity: Double {
        switch clampedProgress {
        case ..<0.30:
            return 0.08
        case ..<0.60:
            return 0.10
        case ..<1.0:
            return 0.12
        default:
            return 0.16
        }
    }
}

// MARK: - Preview

#Preview {
    HabitRowView(
        habit: .init(name: "Water", emoji: "💧", unit: "ml", goal: 2000, step: 250, current: 750, isProtected: true),
        onLogStep: {},
        onUndoStep: {},
        onSetCurrent: { _ in }
    )
    .padding()
}
