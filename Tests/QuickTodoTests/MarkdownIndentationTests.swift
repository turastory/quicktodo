import Foundation
import Testing
@testable import QuickTodo

struct MarkdownIndentationTests {
    @Test
    func outdentCurrentTabbedLineWhenCaretIsInsideLine() {
        let text = "first\n\tsecond\nthird"
        let selection = NSRange(location: 9, length: 0)

        let edit = MarkdownIndentation.outdent(text: text, selectedRange: selection)

        #expect(edit != nil)
        #expect(edit?.text == "first\nsecond\nthird")
        #expect(edit?.selectedRange == NSRange(location: 8, length: 0))
    }

    @Test
    func outdentEverySelectedLineInSelection() {
        let text = "\tfirst\n\tsecond\n\tthird"
        let selection = NSRange(location: 1, length: 20)

        let edit = MarkdownIndentation.outdent(text: text, selectedRange: selection)

        #expect(edit != nil)
        #expect(edit?.text == "first\nsecond\nthird")
        #expect(edit?.selectedRange == NSRange(location: 0, length: 18))
    }

    @Test
    func removeLeadingSpacesAsSingleIndentLevel() {
        let text = "    first"
        let selection = NSRange(location: 6, length: 0)

        let edit = MarkdownIndentation.outdent(text: text, selectedRange: selection)

        #expect(edit != nil)
        #expect(edit?.text == "first")
        #expect(edit?.selectedRange == NSRange(location: 2, length: 0))
    }
}
