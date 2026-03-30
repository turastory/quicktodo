import Foundation

struct MarkdownIndentation {
    struct Edit: Equatable {
        let text: String
        let selectedRange: NSRange
    }

    static func outdent(text: String, selectedRange: NSRange, indentWidth: Int = 4) -> Edit? {
        let nsText = text as NSString
        let clampedRange = clamp(selectedRange, maxLength: nsText.length)
        let lineRange = nsText.lineRange(for: clampedRange)

        var deletions: [NSRange] = []
        var lineLocation = lineRange.location

        while lineLocation < NSMaxRange(lineRange) {
            let currentLineRange = nsText.lineRange(for: NSRange(location: lineLocation, length: 0))
            let removalLength = outdentLength(in: nsText, at: currentLineRange.location, indentWidth: indentWidth)

            if removalLength > 0 {
                deletions.append(NSRange(location: currentLineRange.location, length: removalLength))
            }

            let nextLineLocation = NSMaxRange(currentLineRange)
            if nextLineLocation <= lineLocation {
                break
            }

            lineLocation = nextLineLocation
        }

        guard deletions.isEmpty == false else {
            return nil
        }

        let updatedText = NSMutableString(string: text)
        for deletion in deletions.reversed() {
            updatedText.deleteCharacters(in: deletion)
        }

        let selectionStart = clampedRange.location
        let selectionEnd = NSMaxRange(clampedRange)
        let newSelectionStart = transformedPosition(selectionStart, byDeleting: deletions)
        let newSelectionEnd = transformedPosition(selectionEnd, byDeleting: deletions)

        return Edit(
            text: updatedText as String,
            selectedRange: NSRange(location: newSelectionStart, length: newSelectionEnd - newSelectionStart)
        )
    }

    private static func outdentLength(in text: NSString, at location: Int, indentWidth: Int) -> Int {
        guard location < text.length else {
            return 0
        }

        if text.substring(with: NSRange(location: location, length: 1)) == "\t" {
            return 1
        }

        var spaces = 0
        while location + spaces < text.length, spaces < indentWidth {
            let character = text.substring(with: NSRange(location: location + spaces, length: 1))
            guard character == " " else {
                break
            }

            spaces += 1
        }

        return spaces
    }

    private static func transformedPosition(_ position: Int, byDeleting deletions: [NSRange]) -> Int {
        var removedLength = 0

        for deletion in deletions {
            let deletionEnd = NSMaxRange(deletion)

            if position >= deletionEnd {
                removedLength += deletion.length
                continue
            }

            if position >= deletion.location {
                return deletion.location - removedLength
            }
        }

        return position - removedLength
    }

    private static func clamp(_ range: NSRange, maxLength: Int) -> NSRange {
        let location = max(0, min(range.location, maxLength))
        let upperBound = max(location, min(NSMaxRange(range), maxLength))
        return NSRange(location: location, length: upperBound - location)
    }
}
