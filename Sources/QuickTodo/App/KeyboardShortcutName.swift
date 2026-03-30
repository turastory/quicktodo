@preconcurrency import KeyboardShortcuts

@MainActor
extension KeyboardShortcuts.Name {
    static let toggleQuickTodo = Self(
        "toggleQuickTodo",
        default: .init(.period, modifiers: [.option])
    )
}
