import Foundation
import Testing
@testable import QuickTodo

struct SyncStateRecoveryTests {
    @Test
    func dismissErrorRestoresSavedStateForExistingCleanDocument() {
        let savedAt = Date(timeIntervalSince1970: 1_710_000_000)
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: false,
            hasSelectedFile: true,
            selectedFileExists: true,
            hasPendingConflict: false,
            lastNonErrorState: .saved(savedAt)
        )

        #expect(recovered == .saved(savedAt))
    }

    @Test
    func dismissErrorReturnsEditingForDirtyDocument() {
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: true,
            hasSelectedFile: true,
            selectedFileExists: true,
            hasPendingConflict: false,
            lastNonErrorState: .saved(.now)
        )

        #expect(recovered == .editing)
    }

    @Test
    func dismissErrorReturnsIdleWhenSelectedFileNoLongerExists() {
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: false,
            hasSelectedFile: true,
            selectedFileExists: false,
            hasPendingConflict: false,
            lastNonErrorState: .saved(.now)
        )

        #expect(recovered == .idle)
    }

    @Test
    func dismissErrorPreservesConflictStateWhileConflictBannerIsVisible() {
        let recovered = SyncStateRecovery.stateAfterDismissingError(
            isDirty: false,
            hasSelectedFile: true,
            selectedFileExists: true,
            hasPendingConflict: true,
            lastNonErrorState: .saved(.now)
        )

        #expect(recovered == .conflict)
    }
}
