import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    private static let defaultSize = NSSize(width: 560, height: 460)
    private static let minimumSize = NSSize(width: 520, height: 420)

    init(appModel: AppModel) {
        let rootView = SettingsView()
            .environmentObject(appModel)

        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: Self.defaultSize),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.contentViewController = hostingController
        window.title = "QuickTodo Settings"
        window.titlebarAppearsTransparent = false
        window.toolbarStyle = .automatic
        window.setContentSize(Self.defaultSize)
        window.minSize = Self.minimumSize
        window.center()
        window.isReleasedWhenClosed = false

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func showWindow() {
        guard let window else {
            return
        }

        let currentContentSize = window.contentLayoutRect.size
        let width = max(currentContentSize.width, Self.minimumSize.width)
        let height = max(currentContentSize.height, Self.minimumSize.height)
        window.setContentSize(NSSize(width: width, height: height))
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
