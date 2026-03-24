import Foundation

public enum SyncState: Equatable {
    case idle
    case loading
    case editing
    case saving
    case saved(Date)
    case conflict
    case error
}
