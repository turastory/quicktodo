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
        statusBarController = StatusBarController(delegate: self)

        KeyboardShortcuts.onKeyUp(for: .toggleQuickTodo) { [weak self] in
            self?.togglePanel(nil)
        }

        appModel.bootstrap()

        if appModel.shouldShowPanelOnLaunch {
            panelController?.show()
        }
    }

    @objc func togglePanel(_ sender: Any?) {
        panelController?.toggle()
    }

    @objc func chooseFile(_ sender: Any?) {
        appModel.chooseFile()
    }

    @objc func openSettings(_ sender: Any?) {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(appModel: appModel)
        }

        settingsWindowController?.showWindow()
    }

    @objc func saveDocument(_ sender: Any?) {
        appModel.saveDocument()
    }

    @objc func quit(_ sender: Any?) {
        NSApp.terminate(nil)
    }
}
