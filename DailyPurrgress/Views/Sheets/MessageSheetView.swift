//  MessageSheetView.swift ⌘
//  Created by @jonathaxs.
//  Swift Student Challenge 2026

import SwiftUI

struct InspirationalMessageSheetView: View {
    private static let messageKey = "DailyPurrgress.inspirationalMessageOverride"
    @Environment(\.dismiss) private var dismiss

    @AppStorage(Self.messageKey)
    private var storedMessage: String = ""

    let defaultMessage: String

    @State private var draft: String
    @State private var saveHapticTick: Int = 0
    @State private var resetHapticTick: Int = 0

    private func t(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(defaultMessage: String) {
        self.defaultMessage = defaultMessage

        // Start with stored override if present; otherwise show the default.
        let existing = UserDefaults.standard.string(forKey: Self.messageKey) ?? ""
        _draft = State(initialValue: existing.isEmpty ? defaultMessage : existing)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $draft)
                        .frame(minHeight: 140)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                        .accessibilityLabel(t("inspirationalMessageSheet.field.label"))
                } header: {
                    Text(t("inspirationalMessageSheet.field.label"))
                } footer: {
                    if trimmedDraft.isEmpty {
                        Text(t("inspirationalMessageSheet.field.placeholder"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(t("inspirationalMessageSheet.resetToDefault"), role: .destructive) {
                        // Only update the draft. Persisting happens on Save.
                        draft = defaultMessage
                        resetHapticTick += 1
                    }
                }
            }
            .navigationTitle(t("inspirationalMessageSheet.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t("common.action.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(t("common.action.save")) {
                        // Persist: empty (or whitespace) clears override and falls back to default.
                        let cleaned = trimmedDraft
                        storedMessage = cleaned.isEmpty ? "" : cleaned
                        saveHapticTick += 1
                        dismiss()
                    }
                    .tint(.blue)
                }
            }
            .sensoryFeedback(.success, trigger: saveHapticTick)
            .sensoryFeedback(.impact, trigger: resetHapticTick)
        }
    }
}

#Preview {
    InspirationalMessageSheetView(defaultMessage: "Daily habits don’t have to be loud.\nSometimes, they just purr.")
}
