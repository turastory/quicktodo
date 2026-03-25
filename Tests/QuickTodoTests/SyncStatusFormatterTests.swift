import Foundation
import Testing
@testable import QuickTodo

struct SyncStatusFormatterTests {
    @Test
    func statusLabelUsesUnsavedChangesCopyForEditingState() {
        let editedAt = Date(timeIntervalSince1970: 1_720_000_000)
        let now = Date(timeIntervalSince1970: 1_720_000_180)

        let label = SyncStatusFormatter.statusLabel(
            for: .editing(editedAt),
            relativeTo: now,
            relativeString: { _, _ in "3m ago" }
        )

        #expect(label == "Unsaved changes since 3m ago")
    }

    @Test
    func statusLabelPreservesSavedCopy() {
        let savedAt = Date(timeIntervalSince1970: 1_720_000_000)
        let now = Date(timeIntervalSince1970: 1_720_000_180)

        let label = SyncStatusFormatter.statusLabel(
            for: .saved(savedAt),
            relativeTo: now,
            relativeString: { _, _ in "3m ago" }
        )

        #expect(label == "Saved 3m ago")
    }
}
