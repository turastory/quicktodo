import AppKit
import Combine
import Foundation
import KeyboardShortcuts
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

struct ExternalConflict: Identifiable {
    let id = UUID()
    let content: String
    let detectedAt: Date
}

@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published private(set) var selectedFileURL: URL?
    @Published private(set) var syncState: SyncState = .idle {
        didSet {
            if syncState != .error {
                lastNonErrorSyncState = syncState
            }
        }
    }
    @Published private(set) var launchAtLoginEnabled = true
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var pendingConflict: ExternalConflict?
    @Published private(set) var editorSettings: EditorSettings
    @Published private(set) var recentEditorFontNames: [String]
    @Published var editorText = ""

    private let documentStore = MarkdownDocumentStore()
    private let defaults: UserDefaults
    private let editorFontLibrary: EditorFontLibrary
    private let hotkeyDisplayOverride: String?

    private var directoryMonitor: DirectoryMonitor?
    private var hasBootstrapped = false
    private var lastLoadedContent = ""
    private var lastKnownFingerprint: FileFingerprint?
    private var lastNonErrorSyncState: SyncState = .idle
    private var cancellables = Set<AnyCancellable>()

    private init(
        defaults: UserDefaults = .standard,
        editorFontLibrary: EditorFontLibrary = EditorFontLibrary(),
        observeDefaults: Bool = true,
        hotkeyDisplayOverride: String? = nil
    ) {
        self.defaults = defaults
        self.editorFontLibrary = editorFontLibrary
        self.hotkeyDisplayOverride = hotkeyDisplayOverride

        recentEditorFontNames = []
        editorSettings = EditorSettings.load(
            fontName: nil,
            fontSize: nil,
            fontLibrary: editorFontLibrary
        )

        recentEditorFontNames = (defaults.stringArray(forKey: PreferenceKey.recentEditorFontNames.rawValue) ?? [])
            .filter(editorFontLibrary.isAvailable)

        editorSettings = EditorSettings.load(
            fontName: defaults.string(forKey: PreferenceKey.editorFontName.rawValue),
            fontSize: defaults.object(forKey: PreferenceKey.editorFontSize.rawValue) as? Double,
            fontLibrary: editorFontLibrary
        )

        if defaults.object(forKey: PreferenceKey.launchAtLogin.rawValue) == nil {
            defaults.set(true, forKey: PreferenceKey.launchAtLogin.rawValue)
        }

        launchAtLoginEnabled = defaults.bool(forKey: PreferenceKey.launchAtLogin.rawValue)

        if observeDefaults {
            NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }

    var hasSelectedFile: Bool {
        selectedFileURL != nil
    }

    var metricsText: String {
        let lineCount = max(editorText.components(separatedBy: .newlines).count, 1)
        let characterCount = editorText.count
        return "\(lineCount) lines · \(characterCount) chars"
    }

    var fileDisplayName: String {
        selectedFileURL?.lastPathComponent ?? "No File"
    }

    var filePathDisplay: String {
        selectedFileURL?.path(percentEncoded: false) ?? "Markdown 파일을 아직 선택하지 않았습니다."
    }

    var hotkeyDisplay: String {
        if let hotkeyDisplayOverride {
            return hotkeyDisplayOverride
        }

        return KeyboardShortcuts.getShortcut(for: .toggleQuickTodo)?.description ?? "⌘."
    }

    var editorFontSizeDisplay: String {
        editorSettings.fontSize.formatted(.number.precision(.fractionLength(0...2)))
    }

    var selectedEditorFontName: String {
        editorSettings.fontName
    }

    func bootstrap() {
        guard hasBootstrapped == false else {
            return
        }

        hasBootstrapped = true
        configureLaunchAtLogin(defaultEnabled: launchAtLoginEnabled)

        if let path = defaults.string(forKey: PreferenceKey.selectedFilePath.rawValue) {
            let url = URL(fileURLWithPath: path)
            Task {
                await openFile(at: url)
            }
        }
    }

    func chooseFile() {
        let panel = NSOpenPanel()
        panel.prompt = "Choose"
        panel.message = "Obsidian vault 안의 Markdown 파일을 선택하세요."
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = Self.allowedContentTypes
        panel.directoryURL = selectedFileURL?.deletingLastPathComponent()

        if panel.runModal() == .OK, let url = panel.url {
            Task {
                await openFile(at: url)
            }
        }
    }

    func userEditedText(_ text: String) {
        guard selectedFileURL != nil else {
            editorText = text
            return
        }

        editorText = text
        syncState = .editing(editingStartedAt ?? .now)
    }

    func reloadFromDisk() {
        pendingConflict = nil

        guard let selectedFileURL else {
            return
        }

        Task {
            await openFile(at: selectedFileURL, preserveSelection: true)
        }
    }

    func keepMineAndSave() {
        pendingConflict = nil
        saveDocument(overwriteConflict: true)
    }

    func dismissError() {
        lastErrorMessage = nil
        syncState = SyncStateRecovery.stateAfterDismissingError(
            isDirty: isDirty,
            hasSelectedFile: hasSelectedFile,
            selectedFileExists: selectedFileURL.map { FileManager.default.fileExists(atPath: $0.path) } ?? false,
            hasPendingConflict: pendingConflict != nil,
            lastNonErrorState: lastNonErrorSyncState,
            now: .now
        )
    }

    func saveDocument() {
        saveDocument(overwriteConflict: false)
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try updateLaunchAtLogin(enabled)
            defaults.set(enabled, forKey: PreferenceKey.launchAtLogin.rawValue)
            launchAtLoginEnabled = enabled
        } catch {
            showError(error.localizedDescription)
        }
    }

    func editorFontSections(searchText: String) -> [EditorFontSection] {
        editorFontLibrary.sections(
            searchText: searchText,
            recentFontNames: recentEditorFontNames
        )
    }

    func setEditorFontName(_ fontName: String) {
        let resolvedFontName = editorFontLibrary.resolvedFontName(fontName)

        guard editorSettings.fontName != resolvedFontName || recentEditorFontNames.first != resolvedFontName else {
            return
        }

        editorSettings.fontName = resolvedFontName
        recentEditorFontNames = editorFontLibrary.updatedRecentFontNames(
            byAdding: resolvedFontName,
            to: recentEditorFontNames
        )

        defaults.set(resolvedFontName, forKey: PreferenceKey.editorFontName.rawValue)
        defaults.set(recentEditorFontNames, forKey: PreferenceKey.recentEditorFontNames.rawValue)
    }

    func setEditorFontSize(_ size: Double) {
        let sanitizedSize = EditorSettings.sanitized(size)

        guard editorSettings.fontSize != sanitizedSize else {
            return
        }

        editorSettings.fontSize = sanitizedSize
        defaults.set(sanitizedSize, forKey: PreferenceKey.editorFontSize.rawValue)
    }

    private var isDirty: Bool {
        editorText != lastLoadedContent
    }

    private var editingStartedAt: Date? {
        guard case let .editing(editedAt) = syncState else {
            return nil
        }

        return editedAt
    }

    private func openFile(at url: URL, preserveSelection: Bool = false) async {
        syncState = .loading
        lastErrorMessage = nil

        do {
            let readyURL = try await documentStore.prepareForAccess(at: url)
            let document = try documentStore.read(from: readyURL)
            applyDocument(document, from: readyURL, preserveSelection: preserveSelection)
            startMonitoring(for: readyURL)
        } catch {
            showError(error.localizedDescription)
        }
    }

    private func applyDocument(_ document: MarkdownDocument, from url: URL, preserveSelection: Bool) {
        selectedFileURL = url
        editorText = document.content
        lastLoadedContent = document.content
        lastKnownFingerprint = document.fingerprint
        pendingConflict = nil
        lastErrorMessage = nil
        syncState = .saved(Date())

        if preserveSelection == false {
            defaults.set(url.path, forKey: PreferenceKey.selectedFilePath.rawValue)
        }
    }

    private func saveDocument(overwriteConflict: Bool) {
        Task {
            await saveSnapshot(editorText, overwriteConflict: overwriteConflict)
        }
    }

    private func saveSnapshot(_ snapshot: String, overwriteConflict: Bool) async {
        guard let selectedFileURL else {
            return
        }

        guard pendingConflict == nil || overwriteConflict else {
            return
        }

        let editingStartedAt = self.editingStartedAt ?? .now
        syncState = .saving

        do {
            let readyURL = try await documentStore.prepareForAccess(at: selectedFileURL)
            let writtenDocument = try documentStore.write(content: snapshot, to: readyURL)

            lastLoadedContent = snapshot
            lastKnownFingerprint = writtenDocument.fingerprint
            self.selectedFileURL = readyURL
            lastErrorMessage = nil
            syncState = editorText == snapshot ? .saved(Date()) : .editing(editingStartedAt)
        } catch {
            showError(error.localizedDescription)
        }
    }

    private func startMonitoring(for url: URL) {
        directoryMonitor?.stop()

        let directoryURL = url.deletingLastPathComponent()
        let monitor = DirectoryMonitor(url: directoryURL) { [weak self] in
            Task { @MainActor [weak self] in
                await self?.handlePotentialExternalChange()
            }
        }

        do {
            try monitor.start()
            directoryMonitor = monitor
        } catch {
            showError("파일 변경 감시를 시작하지 못했습니다.")
        }
    }

    private func handlePotentialExternalChange() async {
        guard let selectedFileURL else {
            return
        }

        guard FileManager.default.fileExists(atPath: selectedFileURL.path) else {
            syncState = .error
            lastErrorMessage = "선택한 파일이 이동되었거나 삭제되었습니다. 새 파일을 다시 선택해 주세요."
            return
        }

        do {
            let readyURL = try await documentStore.prepareForAccess(at: selectedFileURL)
            let document = try documentStore.read(from: readyURL)

            guard document.fingerprint != lastKnownFingerprint || document.content != lastLoadedContent else {
                return
            }

            if isDirty {
                pendingConflict = ExternalConflict(content: document.content, detectedAt: Date())
                syncState = .conflict
            } else {
                applyDocument(document, from: readyURL, preserveSelection: true)
            }
        } catch {
            showError(error.localizedDescription)
        }
    }

    private func configureLaunchAtLogin(defaultEnabled enabled: Bool) {
        if enabled {
            do {
                try updateLaunchAtLogin(true)
            } catch {
                showError(error.localizedDescription)
            }
        }
    }

    private func updateLaunchAtLogin(_ enabled: Bool) throws {
        if enabled {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } else {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        }
    }

    private func showError(_ message: String) {
        lastErrorMessage = message
        syncState = .error
    }

    private enum PreferenceKey: String {
        case selectedFilePath
        case launchAtLogin
        case editorFontName
        case editorFontSize
        case recentEditorFontNames
    }

    private static let markdownType = UTType(filenameExtension: "md") ?? .plainText
    private static let allowedContentTypes = [markdownType, .plainText]
}

extension AppModel {
    enum SnapshotFixture {
        case quickTodoEmptyState
        case settings
    }

    static func snapshotPreview(for fixture: SnapshotFixture) -> AppModel {
        let suiteName = "QuickTodoSnapshotPreview.\(fixture).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)

        let fontLibrary = EditorFontLibrary(
            allFontNames: ["Avenir Next", "Helvetica Neue", "Menlo"],
            recommendedFontNames: ["Menlo", "Avenir Next"]
        )
        let appModel = AppModel(
            defaults: defaults,
            editorFontLibrary: fontLibrary,
            observeDefaults: false,
            hotkeyDisplayOverride: "⌘."
        )

        switch fixture {
        case .quickTodoEmptyState:
            appModel.syncState = .idle
            appModel.editorText = ""

        case .settings:
            appModel.selectedFileURL = URL(fileURLWithPath: "/Users/snapshot/Obsidian/Todo.md")
            appModel.syncState = .saved(Date(timeIntervalSinceReferenceDate: 0))
            appModel.editorText = "- Inbox\n- Ship snapshot tests"
            appModel.lastLoadedContent = appModel.editorText
            appModel.editorSettings = EditorSettings(
                fontName: "Menlo",
                fontSize: 16,
                fontLibrary: fontLibrary
            )
            appModel.recentEditorFontNames = ["Menlo", "Avenir Next"]
            appModel.launchAtLoginEnabled = true
        }

        return appModel
    }
}
