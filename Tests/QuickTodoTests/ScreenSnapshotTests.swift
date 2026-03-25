import AppKit
import SwiftUI
import Testing
@testable import QuickTodo

@MainActor
struct ScreenSnapshotTests {
    @Test
    func quickTodoRootEmptyStateCompactWidthMatchesSnapshot() throws {
        try SnapshotTestSupport.assertSnapshot(
            named: "quicktodo-root-empty-320x420",
            size: NSSize(width: 320, height: 420),
            rootView: QuickTodoRootView()
                .environmentObject(AppModel.snapshotPreview(for: .quickTodoEmptyState))
        )
    }

    @Test
    func settingsViewDefaultLayoutMatchesSnapshot() throws {
        try SnapshotTestSupport.assertSnapshot(
            named: "settings-default-560x520",
            size: NSSize(width: 560, height: 520),
            rootView: SettingsView(
                shortcutRecorder: AnyView(
                    Text("⌘.")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(QuickTodoTheme.primaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(width: 94, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(QuickTodoTheme.chrome)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(QuickTodoTheme.line, lineWidth: 1)
                        )
                )
            )
                .environmentObject(AppModel.snapshotPreview(for: .settings))
        )
    }
}
