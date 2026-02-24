//  MessageSheetView.swift ⌘
//  Created by @jonathaxs.
//  Swift Student Challenge 2026

import SwiftUI

struct InspirationalMessageSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("DailyPurrgress.inspirationalMessageOverride")
    private var storedMessage: String = ""

    let defaultMessage: String

    @State private var draft: String
    @State private var isConfirmingReset: Bool = false
    @State private var saveHapticTick: Int = 0

    private func t(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        // Allow save always; saving an empty string clears the override.
        true
    }

    init(defaultMessage: String) {
        self.defaultMessage = defaultMessage

        // Start with stored override if present; otherwise show the default.
        let existing = UserDefaults.standard.string(forKey: "DailyPurrgress.inspirationalMessageOverride") ?? ""
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
                        isConfirmingReset = true
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
                    .disabled(!canSave)
                    .tint(.blue)
                }
            }
            .confirmationDialog(
                t("inspirationalMessageSheet.resetToDefault"),
                isPresented: $isConfirmingReset,
                titleVisibility: .visible
            ) {
                Button(t("inspirationalMessageSheet.resetToDefaultDialogButton"), role: .destructive) {
                    storedMessage = ""
                    draft = defaultMessage
                }
                Button(t("common.action.cancel"), role: .cancel) {}
            } message: {
                Text("\"\(defaultMessage)\"")
            }
            .sensoryFeedback(.success, trigger: saveHapticTick)
        }
    }
}

#Preview {
    InspirationalMessageSheetView(defaultMessage: "Daily habits don’t have to be loud.\nSometimes, they just purr.")
}
