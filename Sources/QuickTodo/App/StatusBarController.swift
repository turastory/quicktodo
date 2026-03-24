import AppKit

@MainActor
final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    init(delegate: AppDelegate) {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "QuickTodo")
            button.imagePosition = .imageLeading
            button.title = "QuickTodo"
        }

        statusItem.menu = buildMenu(delegate: delegate)
    }

    private func buildMenu(delegate: AppDelegate) -> NSMenu {
        let menu = NSMenu()

        menu.addItem(
            withTitle: "Toggle Window",
            action: #selector(AppDelegate.togglePanel(_:)),
            keyEquivalent: ""
        ).target = delegate

        menu.addItem(
            withTitle: "Open File…",
            action: #selector(AppDelegate.chooseFile(_:)),
            keyEquivalent: ""
        ).target = delegate

        menu.addItem(.separator())

        menu.addItem(
            withTitle: "Settings…",
            action: #selector(AppDelegate.openSettings(_:)),
            keyEquivalent: ","
        ).target = delegate

        menu.addItem(.separator())

        menu.addItem(
            withTitle: "Quit QuickTodo",
            action: #selector(AppDelegate.quit(_:)),
            keyEquivalent: "q"
        ).target = delegate

        return menu
    }
}
