import Foundation
import Testing
@testable import QuickTodo

struct EditorSettingsTests {
    @Test
    func loadFallsBackToDefaultsWhenStoredValuesAreMissing() {
        let settings = EditorSettings.load(
            fontChoiceRawValue: nil,
            fontSize: nil
        )

        #expect(settings.fontChoice == .monaspaceNeon)
        #expect(settings.fontSize == 15)
    }

    @Test
    func loadPreservesAnyPositiveFontSizeWithoutClamping() {
        let small = EditorSettings.load(
            fontChoiceRawValue: EditorFontChoice.menlo.rawValue,
            fontSize: 8
        )
        let large = EditorSettings.load(
            fontChoiceRawValue: EditorFontChoice.menlo.rawValue,
            fontSize: 42
        )
        let huge = EditorSettings.load(
            fontChoiceRawValue: EditorFontChoice.menlo.rawValue,
            fontSize: 120
        )

        #expect(small.fontSize == 8)
        #expect(large.fontSize == 42)
        #expect(huge.fontSize == 120)
    }

    @Test
    func loadFallsBackToDefaultWhenStoredFontSizeIsNotPositive() {
        let zero = EditorSettings.load(
            fontChoiceRawValue: EditorFontChoice.sfMono.rawValue,
            fontSize: 0
        )
        let negative = EditorSettings.load(
            fontChoiceRawValue: EditorFontChoice.sfMono.rawValue,
            fontSize: -4
        )

        #expect(zero.fontSize == EditorSettings.defaultFontSize)
        #expect(negative.fontSize == EditorSettings.defaultFontSize)
    }

    @Test
    func loadFallsBackWhenStoredFontChoiceIsUnknown() {
        let settings = EditorSettings.load(
            fontChoiceRawValue: "totally-unknown-font",
            fontSize: 17
        )

        #expect(settings.fontChoice == .monaspaceNeon)
        #expect(settings.fontSize == 17)
    }
}
