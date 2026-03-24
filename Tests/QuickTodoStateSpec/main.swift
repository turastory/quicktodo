import Foundation

@main
struct QuickTodoStateSpec {
    static func main() {
        expectDismissErrorRestoresSavedStateForExistingCleanDocument()
        expectDismissErrorReturnsEditingForDirtyDocument()
        expectDismissErrorReturnsIdleWhenSelectedFileNoLongerExists()
        expectDismissErrorPreservesConflictStateWhileConflictBannerIsVisible()
    }

    private static func expectDismissErrorRestoresSavedStateForExistingCleanDocument() {
        let savedAt = Date(timeIntervalSince1970: 1_710_000_000)
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: false,
            hasSelectedFile: true,
            selectedFileExists: true,
            hasPendingConflict: false,
            lastNonErrorState: .saved(savedAt)
        )

        precondition(recovered == .saved(savedAt), "Expected saved state to be preserved after dismissing an error.")
    }

    private static func expectDismissErrorReturnsEditingForDirtyDocument() {
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: true,
            hasSelectedFile: true,
            selectedFileExists: true,
            hasPendingConflict: false,
            lastNonErrorState: .saved(.now)
        )

        precondition(recovered == .editing, "Expected dirty document to return to editing state after dismissing an error.")
    }

    private static func expectDismissErrorReturnsIdleWhenSelectedFileNoLongerExists() {
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: false,
            hasSelectedFile: true,
            selectedFileExists: false,
            hasPendingConflict: false,
            lastNonErrorState: .saved(.now)
        )

        precondition(recovered == .idle, "Expected missing file to fall back to idle after dismissing an error.")
    }

    private static func expectDismissErrorPreservesConflictStateWhileConflictBannerIsVisible() {
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: false,
            hasSelectedFile: true,
            selectedFileExists: true,
            hasPendingConflict: true,
            lastNonErrorState: .saved(.now)
        )

        precondition(recovered == .conflict, "Expected conflict state to win while a conflict banner is still visible.")
    }
}
