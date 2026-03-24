import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(title: "Workspace", caption: "QuickTodo가 직접 읽고 쓸 Markdown 파일을 고릅니다.")

            VStack(alignment: .leading, spacing: 12) {
                Text(appModel.filePathDisplay)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(QuickTodoTheme.secondaryText)
                    .textSelection(.enabled)

                HStack(spacing: 12) {
                    PrimaryActionButton(title: "Choose File", systemImage: "folder") {
                        appModel.chooseFile()
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 24)

            Divider()
                .overlay(QuickTodoTheme.line)

            sectionHeader(title: "Hotkey", caption: "어디서든 패널을 열고 닫는 글로벌 단축키입니다.")

            VStack(alignment: .leading, spacing: 12) {
                KeyboardShortcuts.Recorder(for: .toggleQuickTodo)
                    .labelsHidden()

                Text("기본값은 `⌘.` 이고, 충돌이 있다면 여기서 바꾸면 됩니다.")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(QuickTodoTheme.secondaryText)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 24)

            Divider()
                .overlay(QuickTodoTheme.line)

            sectionHeader(title: "Behavior", caption: "메뉴바 유틸리티 앱의 기본 실행 방식을 조정합니다.")

            Toggle(isOn: Binding(
                get: { appModel.launchAtLoginEnabled },
                set: { appModel.setLaunchAtLogin($0) }
            )) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Launch at login")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(QuickTodoTheme.primaryText)

                    Text("로그인 직후 QuickTodo를 메뉴바에서 바로 사용할 수 있게 합니다.")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(QuickTodoTheme.secondaryText)
                }
            }
            .toggleStyle(.switch)
            .padding(.horizontal, 22)
            .padding(.bottom, 24)

            Spacer(minLength: 0)
        }
        .frame(minWidth: 520, idealWidth: 560, maxWidth: .infinity, minHeight: 420, idealHeight: 460, maxHeight: .infinity, alignment: .topLeading)
        .background(QuickTodoTheme.canvas)
    }

    private func sectionHeader(title: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(QuickTodoTheme.accent)

            Text(caption)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(QuickTodoTheme.secondaryText)
        }
        .padding(.horizontal, 22)
        .padding(.top, 22)
        .padding(.bottom, 18)
    }
}
