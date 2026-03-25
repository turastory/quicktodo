import Foundation
import Testing
@testable import QuickTodo

struct EditorFontLibraryTests {
    @Test
    func resolvedFontSectionsPlaceRecentFontsAboveRecommendedAndOthers() {
        let library = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Charter", "Fira Code", "Menlo", "SF Mono", "Zapfino"],
            recommendedFontNames: ["SF Mono", "Menlo", "Avenir Next", "Charter"]
        )

        let sections = library.sections(
            searchText: "",
            recentFontNames: ["Fira Code", "Menlo", "Missing Font"]
        )

        #expect(sections.count == 3)
        #expect(sections[0].title == "Recent")
        #expect(sections[0].fontNames == ["Fira Code", "Menlo"])
        #expect(sections[1].title == "Recommended")
        #expect(sections[1].fontNames == ["SF Mono", "Avenir Next", "Charter"])
        #expect(sections[2].title == "All Fonts")
        #expect(sections[2].fontNames == ["Zapfino"])
    }

    @Test
    func sectionsFilterBySearchTextAcrossAllGroups() {
        let library = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Charter", "Fira Code", "Menlo", "SF Mono", "Zapfino"],
            recommendedFontNames: ["SF Mono", "Menlo", "Avenir Next", "Charter"]
        )

        let sections = library.sections(
            searchText: "m",
            recentFontNames: ["Fira Code", "Menlo"]
        )

        #expect(sections.count == 2)
        #expect(sections[0].title == "Recent")
        #expect(sections[0].fontNames == ["Menlo"])
        #expect(sections[1].title == "Recommended")
        #expect(sections[1].fontNames == ["SF Mono"])
    }

    @Test
    func addingRecentFontMovesItToFrontAndCapsHistory() {
        let library = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Charter", "Fira Code", "Menlo", "SF Mono", "Zapfino"],
            recommendedFontNames: ["SF Mono", "Menlo"]
        )

        let updated = library.updatedRecentFontNames(
            byAdding: "Zapfino",
            to: ["Menlo", "Fira Code", "Avenir Next", "Charter", "SF Mono", "Zapfino"],
            limit: 4
        )

        #expect(updated == ["Zapfino", "Menlo", "Fira Code", "Avenir Next"])
    }
}
