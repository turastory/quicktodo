import AppKit

@MainActor
enum AppMenuController {
    static func buildMainMenu() -> NSMenu {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = buildAppMenu()
        mainMenu.addItem(appMenuItem)

        let fileMenuItem = NSMenuItem()
        fileMenuItem.submenu = buildFileMenu()
        mainMenu.addItem(fileMenuItem)

        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = buildEditMenu()
        mainMenu.addItem(editMenuItem)

        let windowMenuItem = NSMenuItem()
        let windowMenu = buildWindowMenu()
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)
        NSApp.windowsMenu = windowMenu

        return mainMenu
    }

    private static func buildAppMenu() -> NSMenu {
        let menu = NSMenu(title: "QuickTodo")

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(AppDelegate.openSettings(_:)), keyEquivalent: ",")
        let quitItem = NSMenuItem(title: "Quit QuickTodo", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q")

        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)

        return menu
    }

    private static func buildFileMenu() -> NSMenu {
        let menu = NSMenu(title: "File")

        let saveItem = NSMenuItem(title: "Save", action: #selector(AppDelegate.saveDocument(_:)), keyEquivalent: "s")
        menu.addItem(saveItem)

        return menu
    }

    private static func buildEditMenu() -> NSMenu {
        let menu = NSMenu(title: "Edit")

        menu.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
        let redoItem = NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(redoItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        menu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        menu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))

        return menu
    }

    private static func buildWindowMenu() -> NSMenu {
        let menu = NSMenu(title: "Window")

        let closeItem = NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        closeItem.target = nil
        menu.addItem(closeItem)

        return menu
    }
}
