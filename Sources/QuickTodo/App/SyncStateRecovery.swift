import Foundation

public enum SyncStateRecovery {
    public static func stateAfterDismissingError(
        isDirty: Bool,
        hasSelectedFile: Bool,
        selectedFileExists: Bool,
        hasPendingConflict: Bool,
        lastNonErrorState: SyncState,
        now: Date = .now
    ) -> SyncState {
        if hasPendingConflict {
            return .conflict
        }

        if isDirty {
            switch lastNonErrorState {
            case let .editing(editedAt):
                return .editing(editedAt)
            default:
                return .editing(now)
            }
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
