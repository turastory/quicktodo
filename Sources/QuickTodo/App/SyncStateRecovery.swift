import Foundation

public enum SyncStateRecovery {
    public static func stateAfterDismissingError(
        isDirty: Bool,
        hasSelectedFile: Bool,
        selectedFileExists: Bool,
        hasPendingConflict: Bool,
        lastNonErrorState: SyncState
    ) -> SyncState {
        if hasPendingConflict {
            return .conflict
        }

        if isDirty {
            return .editing
        }

        guard hasSelectedFile, selectedFileExists else {
            return .idle
        }

        switch lastNonErrorState {
        case let .saved(date):
            return .saved(date)
        case .conflict:
            return .conflict
        default:
            return .idle
        }
    }
}
