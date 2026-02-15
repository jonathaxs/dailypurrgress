//  HabitRowView.swift ⌘ @jonathaxs

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onLogStep: () -> Void
    let onReset: () -> Void
    let onSetCurrent: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isConfirmingReset: Bool = false

    init(
        habit: Habit,
        onLogStep: @escaping () -> Void,
        onReset: @escaping () -> Void,
        onSetCurrent: @escaping (Int) -> Void
    ) {
        self.habit = habit
        self.onLogStep = onLogStep
        self.onReset = onReset
        self.onSetCurrent = onSetCurrent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            slider

            actions
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(habit.name)
        .accessibilityValue(progressAccessibilityValue)
    }
}

// MARK: - Sections

private extension HabitRowView {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
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
    }

    var slider: some View {
        let maxGoal = Double(max(habit.goal, 0))
        let step = Double(max(habit.step, 1))

        let binding = Binding<Double>(
            get: { Double(habit.current) },
            set: { newValue in
                let goal = max(habit.goal, 0)
                guard goal > 0 else { return }

                let stepInt = max(habit.step, 1)
                let rounded = Int((newValue / Double(stepInt)).rounded()) * stepInt
                let clamped = min(max(rounded, 0), goal)

                guard clamped != habit.current else { return }
                onSetCurrent(clamped)
            }
        )

        return Slider(
            value: binding,
            in: 0...maxGoal,
            step: step
        )
        .disabled(maxGoal == 0)
        .accessibilityLabel("Adjust progress")
        .accessibilityValue(sliderAccessibilityValue)
        .accessibilityHint("Swipe up or down to change")
    }

    var actions: some View {
        HStack(spacing: 10) {
            Button {
                isConfirmingReset = true
            } label: {
                Text(Copy.reset)
                    .frame(maxWidth: .infinity, minHeight: 25)
            }
            .confirmationDialog(
                Copy.resetConfirmationTitle(for:"\(habit.emoji)\(habit.name)"),
                isPresented: $isConfirmingReset,
                titleVisibility: .visible
            ) {
                Button(Copy.reset, role: .destructive) {
                    onReset()
                }

                Button(Copy.cancel, role: .cancel) {}
            } message: {
                Text(Copy.resetConfirmationMessage(for: habit.name))
            }
            .buttonStyle(.bordered)
            .disabled(habit.current == 0)
            .accessibilityLabel(Copy.resetTodayAccessibilityLabel)
            .accessibilityHint(Copy.resetTodayAccessibilityHint)

            Button {
                guard habit.isComplete == false else { return }
                onLogStep()
            } label: {
                Text(Copy.logStep(habit.step, unit: habit.unit))
                    .frame(maxWidth: .infinity, minHeight: 25)
            }
            .buttonStyle(.borderedProminent)
            .disabled(habit.isComplete)
            .opacity(habit.isComplete ? 0.6 : 1.0)
            .accessibilityLabel(Copy.logAccessibilityLabel(for: habit.name))
            .accessibilityHint(Copy.logAccessibilityHint(for: habit.name))
            .accessibilityValue(Copy.unitValue(habit.step, unit: habit.unit))
        }
    }

    var progressLine: String {
        "\(habit.current) / \(habit.goal) \(habit.unit)"
    }

    var progressAccessibilityValue: String {
        Copy.percentCompletedValue(Int((habit.progress * 100).rounded()))
    }

    var sliderAccessibilityValue: String {
        "\(habit.current) \(habit.unit)"
    }
}

// MARK: - Preview

#Preview {
    HabitRowView(
        habit: .init(name: "Water", emoji: "💧", unit: "ml", goal: 2000, step: 250, current: 750, isProtected: true),
        onLogStep: {},
        onReset: {},
        onSetCurrent: { _ in }
    )
    .padding()
}
