import AppKit
import SwiftUI

extension Notification.Name {
    static let quickTodoFocusEditor = Notification.Name("QuickTodoFocusEditor")
}

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
final class QuickTodoPanelController: NSObject, NSWindowDelegate {
    private static let autosaveName = "QuickTodoPanelFrame"

    private let panel: FloatingPanel

    init(appModel: AppModel) {
        let contentView = QuickTodoRootView()
            .environmentObject(appModel)

        let hostingController = NSHostingController(rootView: contentView)

        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        super.init()

        panel.contentViewController = hostingController
        panel.isReleasedWhenClosed = false
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.toolbarStyle = .unifiedCompact
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.delegate = self
        panel.setFrameAutosaveName(Self.autosaveName)
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        if panel.setFrameUsingName(Self.autosaveName) == false {
            panel.center()
        }
    }

    func toggle() {
        if panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)

        if panel.isVisible == false {
            panel.alphaValue = 0
            panel.makeKeyAndOrderFront(nil)

            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.16
                panel.animator().alphaValue = 1
            }
        } else {
            panel.makeKeyAndOrderFront(nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            NotificationCenter.default.post(name: .quickTodoFocusEditor, object: nil)
        }
    }

    func hide() {
        panel.orderOut(nil)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hide()
        return false
    }
}
