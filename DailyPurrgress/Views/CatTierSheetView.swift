//  CatTierSheetView.swift ⌘
//  Created by @jonathaxs
//  Swift Student Challenge 2026

import SwiftUI

struct CatTierSheetView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Persisted overrides (empty string = use defaults)

    @AppStorage("DailyPurrgress.catTier.emoji.low") private var lowEmojiStored: String = ""
    @AppStorage("DailyPurrgress.catTier.emoji.medium") private var mediumEmojiStored: String = ""
    @AppStorage("DailyPurrgress.catTier.emoji.high") private var highEmojiStored: String = ""
    @AppStorage("DailyPurrgress.catTier.emoji.complete") private var completeEmojiStored: String = ""

    // Used to force SwiftUI to refresh views that read CatTier values via UserDefaults.
    @AppStorage("DailyPurrgress.catTier.refreshTick") private var refreshTick: Int = 0

    @AppStorage("DailyPurrgress.catTier.title.low") private var lowTitleStored: String = ""
    @AppStorage("DailyPurrgress.catTier.title.medium") private var mediumTitleStored: String = ""
    @AppStorage("DailyPurrgress.catTier.title.high") private var highTitleStored: String = ""
    @AppStorage("DailyPurrgress.catTier.title.complete") private var completeTitleStored: String = ""

    @AppStorage("DailyPurrgress.catTier.subtitle.low") private var lowSubtitleStored: String = ""
    @AppStorage("DailyPurrgress.catTier.subtitle.medium") private var mediumSubtitleStored: String = ""
    @AppStorage("DailyPurrgress.catTier.subtitle.high") private var highSubtitleStored: String = ""
    @AppStorage("DailyPurrgress.catTier.subtitle.complete") private var completeSubtitleStored: String = ""

    // MARK: - Draft fields

    @State private var lowEmojiDraft: String
    @State private var mediumEmojiDraft: String
    @State private var highEmojiDraft: String
    @State private var completeEmojiDraft: String

    @State private var lowTitleDraft: String
    @State private var mediumTitleDraft: String
    @State private var highTitleDraft: String
    @State private var completeTitleDraft: String

    @State private var lowSubtitleDraft: String
    @State private var mediumSubtitleDraft: String
    @State private var highSubtitleDraft: String
    @State private var completeSubtitleDraft: String

    // MARK: - UI State

    @State private var saveHapticTick: Int = 0
    @State private var resetHapticTick: Int = 0

    // MARK: - Init

    init() {
        // Start drafts with the *current effective* values.
        // If an override exists, use it; otherwise use the default xcstrings value.
        _lowEmojiDraft = State(initialValue: CatTier.low.emoji)
        _mediumEmojiDraft = State(initialValue: CatTier.medium.emoji)
        _highEmojiDraft = State(initialValue: CatTier.high.emoji)
        _completeEmojiDraft = State(initialValue: CatTier.complete.emoji)

        _lowTitleDraft = State(initialValue: CatTier.low.title)
        _mediumTitleDraft = State(initialValue: CatTier.medium.title)
        _highTitleDraft = State(initialValue: CatTier.high.title)
        _completeTitleDraft = State(initialValue: CatTier.complete.title)

        _lowSubtitleDraft = State(initialValue: CatTier.low.subtitle)
        _mediumSubtitleDraft = State(initialValue: CatTier.medium.subtitle)
        _highSubtitleDraft = State(initialValue: CatTier.high.subtitle)
        _completeSubtitleDraft = State(initialValue: CatTier.complete.subtitle)
    }

    // MARK: - Localization

    private func t(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    // MARK: - Helpers

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func oneEmoji(_ value: String) -> String {
        String(trimmed(value).prefix(1))
    }

    private func defaultEmoji(for tier: CatTier) -> String {
        switch tier {
        case .low:
            return NSLocalizedString("catTier.low.emoji", comment: "")
        case .medium:
            return NSLocalizedString("catTier.medium.emoji", comment: "")
        case .high:
            return NSLocalizedString("catTier.high.emoji", comment: "")
        case .complete:
            return NSLocalizedString("catTier.complete.emoji", comment: "")
        }
    }

    private func defaultTitle(for tier: CatTier) -> String {
        switch tier {
        case .low:
            return NSLocalizedString("catTier.low.title", comment: "")
        case .medium:
            return NSLocalizedString("catTier.medium.title", comment: "")
        case .high:
            return NSLocalizedString("catTier.high.title", comment: "")
        case .complete:
            return NSLocalizedString("catTier.complete.title", comment: "")
        }
    }

    private func defaultSubtitle(for tier: CatTier) -> String {
        switch tier {
        case .low:
            return NSLocalizedString("catTier.low.subtitle", comment: "")
        case .medium:
            return NSLocalizedString("catTier.medium.subtitle", comment: "")
        case .high:
            return NSLocalizedString("catTier.high.subtitle", comment: "")
        case .complete:
            return NSLocalizedString("catTier.complete.subtitle", comment: "")
        }
    }

    private func saveAndDismiss() {
        // Emoji: persist 1 char override; store "" when it matches the default.
        let lowEmoji = oneEmoji(lowEmojiDraft)
        let mediumEmoji = oneEmoji(mediumEmojiDraft)
        let highEmoji = oneEmoji(highEmojiDraft)
        let completeEmoji = oneEmoji(completeEmojiDraft)

        lowEmojiStored = (lowEmoji == defaultEmoji(for: .low)) ? "" : lowEmoji
        mediumEmojiStored = (mediumEmoji == defaultEmoji(for: .medium)) ? "" : mediumEmoji
        highEmojiStored = (highEmoji == defaultEmoji(for: .high)) ? "" : highEmoji
        completeEmojiStored = (completeEmoji == defaultEmoji(for: .complete)) ? "" : completeEmoji

        // Copy: persist override; store "" when empty OR when it matches the default.
        let lowTitle = trimmed(lowTitleDraft)
        let mediumTitle = trimmed(mediumTitleDraft)
        let highTitle = trimmed(highTitleDraft)
        let completeTitle = trimmed(completeTitleDraft)

        lowTitleStored = (lowTitle.isEmpty || lowTitle == defaultTitle(for: .low)) ? "" : lowTitle
        mediumTitleStored = (mediumTitle.isEmpty || mediumTitle == defaultTitle(for: .medium)) ? "" : mediumTitle
        highTitleStored = (highTitle.isEmpty || highTitle == defaultTitle(for: .high)) ? "" : highTitle
        completeTitleStored = (completeTitle.isEmpty || completeTitle == defaultTitle(for: .complete)) ? "" : completeTitle

        let lowSubtitle = trimmed(lowSubtitleDraft)
        let mediumSubtitle = trimmed(mediumSubtitleDraft)
        let highSubtitle = trimmed(highSubtitleDraft)
        let completeSubtitle = trimmed(completeSubtitleDraft)

        lowSubtitleStored = (lowSubtitle.isEmpty || lowSubtitle == defaultSubtitle(for: .low)) ? "" : lowSubtitle
        mediumSubtitleStored = (mediumSubtitle.isEmpty || mediumSubtitle == defaultSubtitle(for: .medium)) ? "" : mediumSubtitle
        highSubtitleStored = (highSubtitle.isEmpty || highSubtitle == defaultSubtitle(for: .high)) ? "" : highSubtitle
        completeSubtitleStored = (completeSubtitle.isEmpty || completeSubtitle == defaultSubtitle(for: .complete)) ? "" : completeSubtitle

        // Nudge SwiftUI to recompute views that read CatTier overrides indirectly.
        refreshTick += 1

        saveHapticTick += 1
        dismiss()
    }

    private func resetToDefaultConfirmed() {
        // Only reset the draft values.
        // Do NOT touch the stored overrides here; persistence happens on Save.

        lowEmojiDraft = defaultEmoji(for: .low)
        mediumEmojiDraft = defaultEmoji(for: .medium)
        highEmojiDraft = defaultEmoji(for: .high)
        completeEmojiDraft = defaultEmoji(for: .complete)

        lowTitleDraft = defaultTitle(for: .low)
        mediumTitleDraft = defaultTitle(for: .medium)
        highTitleDraft = defaultTitle(for: .high)
        completeTitleDraft = defaultTitle(for: .complete)

        lowSubtitleDraft = defaultSubtitle(for: .low)
        mediumSubtitleDraft = defaultSubtitle(for: .medium)
        highSubtitleDraft = defaultSubtitle(for: .high)
        completeSubtitleDraft = defaultSubtitle(for: .complete)
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            Form {
                Section(t("catTierSheet.low.label")) {
                    labeled(t("catTierSheet.emoji.label")) { emojiField($lowEmojiDraft) }
                    labeled(t("catTierSheet.titleField.label")) { titleField($lowTitleDraft) }
                    labeled(t("catTierSheet.subtitleField.label")) { subtitleField($lowSubtitleDraft) }
                }

                Section(t("catTierSheet.medium.label")) {
                    labeled(t("catTierSheet.emoji.label")) { emojiField($mediumEmojiDraft) }
                    labeled(t("catTierSheet.titleField.label")) { titleField($mediumTitleDraft) }
                    labeled(t("catTierSheet.subtitleField.label")) { subtitleField($mediumSubtitleDraft) }
                }

                Section(t("catTierSheet.high.label")) {
                    labeled(t("catTierSheet.emoji.label")) { emojiField($highEmojiDraft) }
                    labeled(t("catTierSheet.titleField.label")) { titleField($highTitleDraft) }
                    labeled(t("catTierSheet.subtitleField.label")) { subtitleField($highSubtitleDraft) }
                }

                Section(t("catTierSheet.complete.label")) {
                    labeled(t("catTierSheet.emoji.label")) { emojiField($completeEmojiDraft) }
                    labeled(t("catTierSheet.titleField.label")) { titleField($completeTitleDraft) }
                    labeled(t("catTierSheet.subtitleField.label")) { subtitleField($completeSubtitleDraft) }
                }

                Section {
                    Button(t("catTierSheet.resetToDefault"), role: .destructive) {
                        resetToDefaultConfirmed()
                        resetHapticTick += 1
                    }
                }
            }
            .navigationTitle(t("catTierSheet.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(t("common.action.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(t("common.action.save")) {
                        saveAndDismiss()
                    }
                    .tint(.blue)
                }
            }
            .sensoryFeedback(.success, trigger: saveHapticTick)
            .sensoryFeedback(.impact, trigger: resetHapticTick)
        }
    }

    // MARK: - UI Helpers

    @ViewBuilder
    private func labeled(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func emojiField(_ binding: Binding<String>) -> some View {
        TextField("", text: binding)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .onChange(of: binding.wrappedValue) { _, newValue in
                let single = oneEmoji(newValue)
                if newValue != single {
                    binding.wrappedValue = single
                }
            }
    }

    @ViewBuilder
    private func titleField(_ binding: Binding<String>) -> some View {
        TextField("", text: binding)
            .textInputAutocapitalization(.sentences)
    }

    @ViewBuilder
    private func subtitleField(_ binding: Binding<String>) -> some View {
        TextField("", text: binding)
            .textInputAutocapitalization(.sentences)
    }
}

#Preview {
    CatTierSheetView()
}
