import AppKit
import KeyboardShortcuts
import SwiftUI
import Testing
@testable import QuickTodo

@MainActor
struct SnapshotStabilityTests {
    @Test
    func snapshotPreviewIgnoresStoredKeyboardShortcutCustomization() {
        let originalShortcut = KeyboardShortcuts.getShortcut(for: .toggleQuickTodo)
        defer {
            KeyboardShortcuts.setShortcut(originalShortcut, for: .toggleQuickTodo)
        }

        KeyboardShortcuts.setShortcut(
            KeyboardShortcuts.Shortcut(.k, modifiers: [.command, .option]),
            for: .toggleQuickTodo
        )

        let appModel = AppModel.snapshotPreview(for: .settings)

        #expect(appModel.hotkeyDisplay == "⌘.")
    }

    @Test
    func renderedPixelSizeMatchesRequestedLogicalSize() throws {
        let size = NSSize(width: 320, height: 420)

        let pixelSize = try SnapshotTestSupport.renderedPixelSize(
            for: QuickTodoRootView()
                .environmentObject(AppModel.snapshotPreview(for: .quickTodoEmptyState)),
            size: size
        )

        #expect(pixelSize == size)
    }
}
