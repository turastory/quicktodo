import Foundation
import Testing
@testable import QuickTodo

struct EditorSettingsTests {
    @Test
    func loadFallsBackToDefaultsWhenStoredValuesAreMissing() {
        let fontLibrary = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Menlo", "SF Mono"],
            recommendedFontNames: ["SF Mono", "Menlo"]
        )
        let settings = EditorSettings.load(
            fontName: nil,
            fontSize: nil,
            fontLibrary: fontLibrary
        )

        #expect(settings.fontName == "SF Mono")
        #expect(settings.fontSize == 15)
    }

    @Test
    func loadPreservesAnyPositiveFontSizeWithoutClamping() {
        let fontLibrary = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Menlo", "SF Mono"],
            recommendedFontNames: ["SF Mono", "Menlo"]
        )
        let small = EditorSettings.load(
            fontName: "Menlo",
            fontSize: 8,
            fontLibrary: fontLibrary
        )
        let large = EditorSettings.load(
            fontName: "Menlo",
            fontSize: 42,
            fontLibrary: fontLibrary
        )
        let huge = EditorSettings.load(
            fontName: "Menlo",
            fontSize: 120,
            fontLibrary: fontLibrary
        )

        #expect(small.fontSize == 8)
        #expect(large.fontSize == 42)
        #expect(huge.fontSize == 120)
    }

    @Test
    func loadFallsBackToDefaultWhenStoredFontSizeIsNotPositive() {
        let fontLibrary = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Menlo", "SF Mono"],
            recommendedFontNames: ["SF Mono", "Menlo"]
        )
        let zero = EditorSettings.load(
            fontName: "SF Mono",
            fontSize: 0,
            fontLibrary: fontLibrary
        )
        let negative = EditorSettings.load(
            fontName: "SF Mono",
            fontSize: -4,
            fontLibrary: fontLibrary
        )

        #expect(zero.fontSize == EditorSettings.defaultFontSize)
        #expect(negative.fontSize == EditorSettings.defaultFontSize)
    }

    @Test
    func loadFallsBackWhenStoredFontChoiceIsUnknown() {
        let fontLibrary = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Menlo", "SF Mono"],
            recommendedFontNames: ["SF Mono", "Menlo"]
        )
        let settings = EditorSettings.load(
            fontName: "totally-unknown-font",
            fontSize: 17,
            fontLibrary: fontLibrary
        )

        #expect(settings.fontName == "SF Mono")
        #expect(settings.fontSize == 17)
    }
}
