import AppKit
import KeyboardShortcuts

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appModel = AppModel.shared

    private var statusBarController: StatusBarController?
    private var panelController: QuickTodoPanelController?
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = AppMenuController.buildMainMenu()

        panelController = QuickTodoPanelController(appModel: appModel)
        settingsWindowController = SettingsWindowController(appModel: appModel)
        statusBarController = StatusBarController(delegate: self)

        KeyboardShortcuts.onKeyUp(for: .toggleQuickTodo) { [weak self] in
            self?.togglePanel(nil)
        }

        appModel.bootstrap()
    }

    @objc func togglePanel(_ sender: Any?) {
        panelController?.toggle()
    }

    @objc func chooseFile(_ sender: Any?) {
        appModel.chooseFile()
    }

    @objc func openSettings(_ sender: Any?) {
        settingsWindowController?.showWindow()
    }

    @objc func quit(_ sender: Any?) {
        NSApp.terminate(nil)
    }
}
