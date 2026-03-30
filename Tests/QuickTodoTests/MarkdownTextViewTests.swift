import AppKit
import Testing
@testable import QuickTodo

@MainActor
struct MarkdownTextViewTests {
    @Test
    func textDidChangeDoesNotRewriteSelectionDuringLocalTypingHighlighting() {
        let settings = EditorSettings(fontName: "SF Mono")
        let coordinator = MarkdownTextView.Coordinator(
            onTextChange: { _ in },
            settings: settings
        )
        let textView = SelectionTrackingTextView(frame: NSRect(x: 0, y: 0, width: 320, height: 200))
        textView.string = "- [ ] Cursor"
        textView.font = settings.editorFont
        textView.selectedRange = NSRange(location: 5, length: 0)
        textView.selectionAssignmentCount = 0
        coordinator.textView = textView

        coordinator.textDidChange(Notification(name: NSText.didChangeNotification, object: textView))

        #expect(textView.selectionAssignmentCount == 0)
        #expect(textView.selectedRange() == NSRange(location: 5, length: 0))
    }
}

private final class SelectionTrackingTextView: NSTextView {
    var selectionAssignmentCount = 0

    override var selectedRanges: [NSValue] {
        didSet {
            selectionAssignmentCount += 1
        }
    }
}
