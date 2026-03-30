import AppKit
import SwiftUI

private final class EditorTextView: NSTextView {
    var onBacktab: (() -> Bool)?

    override func insertBacktab(_ sender: Any?) {
        if onBacktab?() == true {
            return
        }

        super.insertBacktab(sender)
    }
}

struct MarkdownTextView: NSViewRepresentable {
    let text: String
    let settings: EditorSettings
    let onTextChange: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextChange: onTextChange, settings: settings)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        let textView = EditorTextView()
        textView.delegate = context.coordinator
        textView.string = text
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.insertionPointColor = QuickTodoTheme.accentNSColor
        textView.textColor = NSColor.labelColor
        textView.font = settings.editorFont
        textView.textContainerInset = NSSize(width: 26, height: 28)
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.minSize = .zero
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        textView.textContainer?.lineFragmentPadding = 0
        textView.onBacktab = { [weak coordinator = context.coordinator] in
            coordinator?.outdentSelection() ?? false
        }

        context.coordinator.textView = textView
        context.coordinator.applyHighlighting()
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.handleFocusEditorNotification),
            name: .quickTodoFocusEditor,
            object: nil
        )

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else {
            return
        }

        context.coordinator.settings = settings

        if textView.string != text {
            context.coordinator.isApplyingModelUpdate = true
            textView.string = text
            context.coordinator.applyHighlighting()
            context.coordinator.isApplyingModelUpdate = false
        } else if context.coordinator.applySettingsIfNeeded() {
            context.coordinator.applyHighlighting()
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        private static let headingPattern = try? NSRegularExpression(pattern: #"(?m)^(#{1,6}\s.*)$"#)
        private static let bulletPattern = try? NSRegularExpression(pattern: #"(?m)^(\s*[-+*]\s+)(.*)$"#)
        private static let orderedPattern = try? NSRegularExpression(pattern: #"(?m)^(\s*\d+\.\s+)(.*)$"#)
        private static let taskPattern = try? NSRegularExpression(pattern: #"(?m)^(\s*[-+*]\s+\[[ xX]\]\s+)(.*)$"#)
        private static let quotePattern = try? NSRegularExpression(pattern: #"(?m)^(\s*>\s+)(.*)$"#)
        private static let linkPattern = try? NSRegularExpression(pattern: #"(https?://[^\s\)>\]]+)"#)

        let onTextChange: (String) -> Void
        var settings: EditorSettings
        private var lastAppliedSettings: EditorSettings?

        weak var textView: NSTextView?
        var isApplyingModelUpdate = false

        init(onTextChange: @escaping (String) -> Void, settings: EditorSettings) {
            self.onTextChange = onTextChange
            self.settings = settings
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        func textDidChange(_ notification: Notification) {
            guard isApplyingModelUpdate == false, let textView else {
                return
            }

            applyHighlighting()
            onTextChange(textView.string)
        }

        @objc func handleFocusEditorNotification() {
            textView?.window?.makeFirstResponder(textView)
        }

        @discardableResult
        func applySettingsIfNeeded() -> Bool {
            guard let textView else {
                return false
            }

            guard lastAppliedSettings != settings else {
                return false
            }

            textView.font = settings.editorFont
            lastAppliedSettings = settings
            return true
        }

        func applyHighlighting() {
            guard let textView, let textStorage = textView.textStorage else {
                return
            }

            _ = applySettingsIfNeeded()

            let nsString = textStorage.string as NSString
            let fullRange = NSRange(location: 0, length: nsString.length)
            let selectedRanges = textView.selectedRanges

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.13

            let baseAttributes: [NSAttributedString.Key: Any] = [
                .font: settings.editorFont,
                .foregroundColor: NSColor.labelColor,
                .paragraphStyle: paragraphStyle,
            ]

            textStorage.beginEditing()
            textStorage.setAttributes(baseAttributes, range: fullRange)

            applyPattern(Self.headingPattern, to: textStorage, in: fullRange) { match, storage in
                storage.addAttributes([
                    .foregroundColor: QuickTodoTheme.accentNSColor,
                    .font: settings.emphasizedFont,
                ], range: match.range(at: 1))
            }

            applyPattern(Self.taskPattern, to: textStorage, in: fullRange) { match, storage in
                storage.addAttribute(.foregroundColor, value: QuickTodoTheme.warmAccentNSColor, range: match.range(at: 1))
                storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: match.range(at: 2))
            }

            applyPattern(Self.bulletPattern, to: textStorage, in: fullRange) { match, storage in
                storage.addAttribute(.foregroundColor, value: QuickTodoTheme.accentNSColor, range: match.range(at: 1))
                storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: match.range(at: 2))
            }

            applyPattern(Self.orderedPattern, to: textStorage, in: fullRange) { match, storage in
                storage.addAttribute(.foregroundColor, value: QuickTodoTheme.accentNSColor, range: match.range(at: 1))
                storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: match.range(at: 2))
            }

            applyPattern(Self.quotePattern, to: textStorage, in: fullRange) { match, storage in
                storage.addAttributes([
                    .foregroundColor: QuickTodoTheme.syntaxSecondaryNSColor,
                    .font: settings.editorFont,
                ], range: match.range(at: 1))
                storage.addAttribute(.foregroundColor, value: QuickTodoTheme.syntaxSecondaryNSColor, range: match.range(at: 2))
            }

            applyPattern(Self.linkPattern, to: textStorage, in: fullRange) { match, storage in
                storage.addAttributes([
                    .foregroundColor: QuickTodoTheme.linkNSColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .cursor: NSCursor.pointingHand,
                ], range: match.range(at: 1))
            }

            textStorage.endEditing()
            textView.typingAttributes = baseAttributes
            textView.selectedRanges = selectedRanges
        }

        func outdentSelection() -> Bool {
            guard
                let textView,
                let textStorage = textView.textStorage
            else {
                return false
            }

            let selectedRange = textView.selectedRange()
            let fullRange = NSRange(location: 0, length: textStorage.length)

            guard let edit = MarkdownIndentation.outdent(text: textView.string, selectedRange: selectedRange) else {
                return true
            }

            guard textView.shouldChangeText(in: fullRange, replacementString: edit.text) else {
                return true
            }

            textStorage.replaceCharacters(in: fullRange, with: edit.text)
            textView.setSelectedRange(edit.selectedRange)
            textView.didChangeText()
            return true
        }

        private func applyPattern(
            _ expression: NSRegularExpression?,
            to storage: NSTextStorage,
            in range: NSRange,
            handler: (NSTextCheckingResult, NSTextStorage) -> Void
        ) {
            guard let expression else {
                return
            }

            expression.matches(in: storage.string, range: range).forEach { match in
                handler(match, storage)
            }
        }
    }
}
