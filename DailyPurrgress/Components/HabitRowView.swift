//  HabitRowView.swift ⌘ @jonathaxs

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let onLogStep: () -> Void
    let onReset: () -> Void
    let onSetCurrent: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var sliderValue: Double
    @State private var isDragging: Bool = false

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
        _sliderValue = State(initialValue: Double(habit.current))
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
        .onChange(of: habit.current) { _, newValue in
            guard isDragging == false else { return }
            sliderValue = Double(newValue)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(habit.name)
        .accessibilityValue(progressAccessibilityValue)
    }
}

// MARK: - Sections

private extension HabitRowView {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
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

        return Slider(
            value: $sliderValue,
            in: 0...maxGoal,
            step: step
        ) { editing in
            isDragging = editing
            if editing == false {
                commitSliderValue()
            }
        }
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
                    .frame(maxWidth: .infinity)
            }
            .confirmationDialog(
                "Reset this habit?",
                isPresented: $isConfirmingReset,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    onReset()
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear your progress for today.")
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
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(habit.isComplete)
            .opacity(habit.isComplete ? 0.6 : 1.0)
            .accessibilityLabel(Copy.logWaterAccessibilityLabel)
            .accessibilityHint(Copy.logWaterAccessibilityHint)
            .accessibilityValue(Copy.unitValue(habit.step, unit: habit.unit))
        }
    }

    func commitSliderValue() {
        let goal = max(habit.goal, 0)
        guard goal > 0 else {
            if sliderValue != 0 {
                sliderValue = 0
            }
            return
        }

        let step = max(habit.step, 1)
        let rounded = Int((sliderValue / Double(step)).rounded()) * step
        let clamped = min(max(rounded, 0), goal)

        if clamped != habit.current {
            if reduceMotion {
                sliderValue = Double(clamped)
            } else {
                withAnimation(.easeInOut(duration: 0.12)) {
                    sliderValue = Double(clamped)
                }
            }

            onSetCurrent(clamped)
        } else {
            sliderValue = Double(clamped)
        }
    }

    var progressLine: String {
        "\(habit.current) / \(habit.goal) \(habit.unit)"
    }

    var progressAccessibilityValue: String {
        Copy.percentCompletedValue(Int((habit.progress * 100).rounded()))
    }

    var sliderAccessibilityValue: String {
        "\(Int(sliderValue)) \(habit.unit)"
    }
}

// MARK: - Preview

#Preview {
    HabitRowView(
        habit: .init(name: "Water", unit: "ml", goal: 2000, step: 250, current: 750, isProtected: true),
        onLogStep: {},
        onReset: {},
        onSetCurrent: { _ in }
    )
    .padding()
}
