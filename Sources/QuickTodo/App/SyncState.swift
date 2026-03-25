import Foundation

public enum SyncState: Equatable {
    case idle
    case loading
    case editing(Date)
    case saving
    case saved(Date)
    case conflict
    case error
}
