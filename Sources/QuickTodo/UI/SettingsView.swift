import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var isFontSizeFieldFocused: Bool
    @State private var editorFontSizeInput = ""
    @State private var editorFontSearchText = ""
    private let shortcutRecorder: AnyView

    init(shortcutRecorder: AnyView? = nil) {
        if let shortcutRecorder {
            self.shortcutRecorder = shortcutRecorder
        } else {
            self.shortcutRecorder = AnyView(
                KeyboardShortcuts.Recorder(for: .toggleQuickTodo)
                    .labelsHidden()
            )
        }
    }

    var body: some View {
        ScrollView {
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
                    shortcutRecorder

                    Text("기본값은 `⌘.` 이고, 충돌이 있다면 여기서 바꾸면 됩니다.")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(QuickTodoTheme.secondaryText)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)

                Divider()
                    .overlay(QuickTodoTheme.line)

                sectionHeader(title: "Editor", caption: "에디터에서 사용할 글꼴과 글자 크기를 바로 바꿉니다.")

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Editor Font")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(QuickTodoTheme.primaryText)

                        Text(appModel.selectedEditorFontName)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(QuickTodoTheme.accent)

                        TextField("Search fonts", text: $editorFontSearchText)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13, weight: .regular, design: .default))

                        EditorFontListView(
                            sections: appModel.editorFontSections(searchText: editorFontSearchText),
                            selectedFontName: appModel.selectedEditorFontName,
                            onSelectFont: appModel.setEditorFontName
                        )
                        .frame(height: 240)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Text Size")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(QuickTodoTheme.primaryText)

                            Spacer()
                        }

                        TextField("15", text: $editorFontSizeInput)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .frame(maxWidth: 120, alignment: .leading)
                            .focused($isFontSizeFieldFocused)
                            .onSubmit(commitEditorFontSizeInput)
                            .onChange(of: isFontSizeFieldFocused) { isFocused in
                                if isFocused == false {
                                    commitEditorFontSizeInput()
                                }
                            }

                        Text("숫자를 직접 입력하면 적용됩니다.")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundStyle(QuickTodoTheme.secondaryText)
                    }
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
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(minWidth: 520, idealWidth: 560, maxWidth: .infinity, minHeight: 460, idealHeight: 520, maxHeight: .infinity, alignment: .topLeading)
        .background(QuickTodoTheme.canvas)
        .onAppear {
            syncEditorFontSizeInput()
        }
        .onChange(of: appModel.editorSettings.fontSize) { _ in
            guard isFontSizeFieldFocused == false else {
                return
            }

            syncEditorFontSizeInput()
        }
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

    private func commitEditorFontSizeInput() {
        let trimmed = editorFontSizeInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let fontSize = Double(trimmed), fontSize.isFinite, fontSize > 0 else {
            syncEditorFontSizeInput()
            return
        }

        appModel.setEditorFontSize(fontSize)
        syncEditorFontSizeInput()
    }

    private func syncEditorFontSizeInput() {
        editorFontSizeInput = appModel.editorFontSizeDisplay
    }
}

private struct EditorFontListView: View {
    let sections: [EditorFontSection]
    let selectedFontName: String
    let onSelectFont: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(sections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(QuickTodoTheme.secondaryText)

                        ForEach(section.fontNames, id: \.self) { fontName in
                            Button {
                                onSelectFont(fontName)
                            } label: {
                                HStack(spacing: 10) {
                                    Text(fontName)
                                        .font(.system(size: 13, weight: .medium, design: .default))
                                        .foregroundStyle(
                                            fontName == selectedFontName ? QuickTodoTheme.accent : QuickTodoTheme.primaryText
                                        )

                                    Spacer()

                                    if fontName == selectedFontName {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(QuickTodoTheme.accent)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(fontName == selectedFontName ? QuickTodoTheme.chrome : .clear)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if sections.isEmpty {
                    Text("검색 결과가 없습니다.")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(QuickTodoTheme.secondaryText)
                        .padding(.vertical, 8)
                }
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(QuickTodoTheme.chrome)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(QuickTodoTheme.line, lineWidth: 1)
        )
    }
}
