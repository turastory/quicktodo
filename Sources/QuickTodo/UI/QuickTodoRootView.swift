import SwiftUI

struct QuickTodoRootView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            DocumentHeaderView(
                fileDisplayName: appModel.fileDisplayName,
                filePathDisplay: appModel.filePathDisplay
            )

            if let pendingConflict = appModel.pendingConflict {
                ConflictBanner(
                    detectedAt: pendingConflict.detectedAt,
                    onReload: appModel.reloadFromDisk,
                    onKeepMine: appModel.keepMineAndSave
                )
            }

            if let errorMessage = appModel.lastErrorMessage {
                ErrorBanner(
                    message: errorMessage,
                    onChooseFile: appModel.chooseFile,
                    onDismiss: appModel.dismissError
                )
            }

            Divider()
                .overlay(QuickTodoTheme.line)

            EditorContentView(
                hasSelectedFile: appModel.hasSelectedFile,
                editorText: appModel.editorText,
                editorSettings: appModel.editorSettings,
                onTextChange: appModel.userEditedText,
                onChooseFile: appModel.chooseFile
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .overlay(QuickTodoTheme.line)

            StatusFooterView(
                syncState: appModel.syncState,
                metricsText: appModel.metricsText,
                hotkeyDisplay: appModel.hotkeyDisplay
            )
        }
        .frame(minWidth: 320, minHeight: 420)
        .background(QuickTodoTheme.canvas)
    }
}

private struct DocumentHeaderView: View {
    let fileDisplayName: String
    let filePathDisplay: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(fileDisplayName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(QuickTodoTheme.primaryText)
                    .lineLimit(1)
                    .accessibilityLabel("현재 파일")

                Text(filePathDisplay)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(QuickTodoTheme.secondaryText)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .accessibilityLabel("파일 경로")
            }

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(QuickTodoTheme.chrome)
        .accessibilityElement(children: .combine)
    }
}

private struct EditorContentView: View {
    let hasSelectedFile: Bool
    let editorText: String
    let editorSettings: EditorSettings
    let onTextChange: (String) -> Void
    let onChooseFile: () -> Void

    var body: some View {
        Group {
            if hasSelectedFile {
                MarkdownTextView(
                    text: editorText,
                    settings: editorSettings,
                    onTextChange: onTextChange
                )
            } else {
                EmptyStateView(onChooseFile: onChooseFile)
            }
        }
    }
}

private struct StatusFooterView: View {
    let syncState: SyncState
    let metricsText: String
    let hotkeyDisplay: String

    var body: some View {
        HStack(spacing: 14) {
            SyncStatusView(syncState: syncState)

            Spacer()

            Text(metricsText)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(QuickTodoTheme.secondaryText)
                .accessibilityLabel("문서 통계")

            Text(hotkeyDisplay)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(QuickTodoTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .overlay(
                    Capsule()
                        .stroke(QuickTodoTheme.line, lineWidth: 1)
                )
                .accessibilityLabel("토글 단축키")
                .accessibilityValue(hotkeyDisplay)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(QuickTodoTheme.chrome)
    }
}

private struct SyncStatusView: View {
    let syncState: SyncState

    var body: some View {
        Group {
            switch syncState {
            case let .editing(editedAt):
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    statusText(for: .editing(editedAt), relativeTo: context.date)
                }
            case let .saved(savedAt):
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    statusText(for: .saved(savedAt), relativeTo: context.date)
                }
            default:
                statusText(for: syncState, relativeTo: .now)
            }
        }
        .accessibilityLabel("동기화 상태")
        .accessibilityValue(Self.statusLabel(for: syncState, relativeTo: .now))
    }

    @ViewBuilder
    private func statusText(for state: SyncState, relativeTo now: Date) -> some View {
        Text(Self.statusLabel(for: state, relativeTo: now))
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(syncColor(for: state))
    }

    private func syncColor(for state: SyncState) -> Color {
        switch state {
        case .idle, .loading, .saving:
            QuickTodoTheme.secondaryText
        case .editing, .saved:
            QuickTodoTheme.accent
        case .conflict:
            QuickTodoTheme.warmAccent
        case .error:
            QuickTodoTheme.danger
        }
    }

    private static func statusLabel(for state: SyncState, relativeTo now: Date) -> String {
        SyncStatusFormatter.statusLabel(for: state, relativeTo: now)
    }
}

private struct EmptyStateView: View {
    let onChooseFile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Open one Markdown file")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(QuickTodoTheme.primaryText)

            Text("Obsidian vault 안의 todo 파일 하나만 연결해 두면, QuickTodo는 그 원문을 직접 읽고 저장합니다.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundStyle(QuickTodoTheme.secondaryText)
                .frame(maxWidth: 420, alignment: .leading)

            HStack(spacing: 12) {
                PrimaryActionButton(title: "Choose File", systemImage: "folder", action: onChooseFile)
            }

            Text("Tip · iCloud Drive 안의 `.md` 파일도 그대로 사용합니다.")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(QuickTodoTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 28)
        .padding(.top, 32)
        .accessibilityElement(children: .contain)
    }
}

struct ConflictBanner: View {
    let detectedAt: Date
    let onReload: () -> Void
    let onKeepMine: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(QuickTodoTheme.warmAccent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("External change detected")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(QuickTodoTheme.primaryText)

                Text("다른 앱이 파일을 수정했습니다. \(detectedAt.formatted(date: .omitted, time: .shortened)) 기준 내용과 충돌 중입니다.")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(QuickTodoTheme.secondaryText)
            }

            Spacer()

            SecondaryActionButton(title: "Reload", systemImage: "arrow.clockwise", action: onReload)
            PrimaryActionButton(title: "Keep Mine", systemImage: "square.and.arrow.down", action: onKeepMine)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(QuickTodoTheme.chrome)
        .accessibilityElement(children: .contain)
    }
}

struct ErrorBanner: View {
    let message: String
    let onChooseFile: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(QuickTodoTheme.danger)
                .accessibilityHidden(true)

            Text(message)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundStyle(QuickTodoTheme.primaryText)
                .accessibilityLabel("오류 메시지")

            Spacer()

            SecondaryActionButton(title: "Choose File", systemImage: "folder", action: onChooseFile)
            SecondaryActionButton(title: "Dismiss", systemImage: "xmark", action: onDismiss)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(QuickTodoTheme.chrome)
        .accessibilityElement(children: .contain)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(0.82))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(QuickTodoTheme.accent)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }
}

struct SecondaryActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(QuickTodoTheme.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(QuickTodoTheme.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }
}
