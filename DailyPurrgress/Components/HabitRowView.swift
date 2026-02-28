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

    private func t(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private func tf(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), arguments: args)
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
                onUndoStep()
            } label: {
                Text(t("common.action.undo"))
            }
            .buttonStyle(HabitRowButtonStyle(variant: .bordered))
            .pressScale(pressedScale: 1.15, response: 0.25, dampingFraction: 0.40)
            .disabled(habit.current == 0)
            .accessibilityLabel(t("a11y.habit.undo.label"))
            .accessibilityHint(t("a11y.habit.undo.hint"))

            Button {
                onLogStep()
            } label: {
                Text(t("common.action.log"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(HabitRowButtonStyle(variant: .prominent))
            .pressScale(pressedScale: 1.15, response: 0.25, dampingFraction: 0.40)
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

// MARK: - Button Style

/// Gesture-driven press scale that works well inside `ScrollView`.
/// We avoid relying on `configuration.isPressed` because scroll views can delay the pressed state
/// while deciding between a tap and a drag.
private struct PressScaleEffect: ViewModifier {
    var pressedScale: CGFloat = 1.15
    var response: Double = 0.25
    var dampingFraction: Double = 0.40

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    @GestureState private var isPressed: Bool = false

    func body(content: Content) -> some View {
        let scale: CGFloat = (reduceMotion || !isEnabled) ? 1.0 : (isPressed ? pressedScale : 1.0)

        return content
            .scaleEffect(scale)
            .animation(
                reduceMotion ? nil : .spring(response: response, dampingFraction: dampingFraction),
                value: isPressed
            )
            // Using a 0-distance drag lets us detect touch-down immediately.
            // `simultaneousGesture` keeps scrolling behavior intact.
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
    }
}

private extension View {
    func pressScale(
        pressedScale: CGFloat = 1.15,
        response: Double = 0.25,
        dampingFraction: Double = 0.40
    ) -> some View {
        modifier(
            PressScaleEffect(
                pressedScale: pressedScale,
                response: response,
                dampingFraction: dampingFraction
            )
        )
    }
}

private struct HabitRowButtonStyle: ButtonStyle {
    enum Variant {
        case bordered
        case prominent
    }

    let variant: Variant

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .frame(maxWidth: .infinity, minHeight: 25)
            .contentShape(Rectangle())
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(background(isPressed: isPressed), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
            .overlay {
                if variant == .bordered {
                    RoundedRectangle(cornerRadius: 21, style: .continuous)
                        .strokeBorder(.secondary.opacity(0.25), lineWidth: 1)
                }
            }
            .foregroundStyle(foreground)
            .opacity(isEnabled ? 1.0 : 0.6)
    }

    private var foreground: some ShapeStyle {
        switch variant {
        case .bordered:
            return AnyShapeStyle(Color.primary)
        case .prominent:
            return AnyShapeStyle(Color.white)
        }
    }

    private func background(isPressed: Bool) -> AnyShapeStyle {
        switch variant {
        case .bordered:
            return AnyShapeStyle(.thinMaterial)
        case .prominent:
            return AnyShapeStyle(Color.accentColor.opacity(isPressed ? 0.85 : 1.0))
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
