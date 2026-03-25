import Foundation

enum SyncStatusFormatter {
    static func statusLabel(
        for state: SyncState,
        relativeTo now: Date,
        relativeString: (Date, Date) -> String = defaultRelativeString
    ) -> String {
        switch state {
        case .idle:
            return "Ready"
        case .loading:
            return "Opening"
        case let .editing(editedAt):
            return "Unsaved changes since \(relativeString(editedAt, now))"
        case .saving:
            return "Saving"
        case let .saved(savedAt):
            return "Saved \(relativeString(savedAt, now))"
        case .conflict:
            return "Conflict"
        case .error:
            return "Attention"
        }
    }

    private static func defaultRelativeString(from date: Date, to now: Date) -> String {
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        return relativeFormatter.localizedString(for: date, relativeTo: now)
    }
}
