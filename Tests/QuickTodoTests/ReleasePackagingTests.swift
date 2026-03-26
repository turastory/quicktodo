import Foundation
import Testing

struct ReleasePackagingTests {
    @Test
    func releaseZipContainsCodesignVerifiableAppBundle() throws {
        let rootDirectory = try repoRoot()
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let checkoutDirectory = temporaryDirectory.appendingPathComponent("checkout", isDirectory: true)
        let extractionDirectory = temporaryDirectory.appendingPathComponent("extracted", isDirectory: true)

        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )
        defer {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }

        try run(
            "/usr/bin/rsync",
            arguments: [
                "-a",
                "--delete",
                "--exclude",
                ".build",
                "--exclude",
                "dist",
                "\(rootDirectory.path(percentEncoded: false))/",
                checkoutDirectory.path(percentEncoded: false),
            ]
        )

        try FileManager.default.createDirectory(
            at: extractionDirectory,
            withIntermediateDirectories: true
        )

        try run(
            "/bin/bash",
            arguments: [
                "Scripts/create-release-zip.sh",
                "0.1.4",
                "999",
            ],
            currentDirectoryURL: checkoutDirectory
        )

        let zipURL = checkoutDirectory.appendingPathComponent("dist/QuickTodo.zip")

        try run(
            "/usr/bin/ditto",
            arguments: [
                "-x",
                "-k",
                zipURL.path(percentEncoded: false),
                extractionDirectory.path(percentEncoded: false),
            ]
        )

        let appURL = extractionDirectory.appendingPathComponent("QuickTodo.app")

        try run(
            "/usr/bin/codesign",
            arguments: [
                "--verify",
                "--deep",
                "--strict",
                "--verbose=2",
                appURL.path(percentEncoded: false),
            ]
        )

        let iconURL = appURL
            .appendingPathComponent("Contents/Resources/QuickTodo.icns")
        let plistURL = appURL
            .appendingPathComponent("Contents/Info.plist")

        #expect(FileManager.default.fileExists(atPath: iconURL.path(percentEncoded: false)))

        let iconName = try run(
            "/usr/libexec/PlistBuddy",
            arguments: [
                "-c",
                "Print :CFBundleIconFile",
                plistURL.path(percentEncoded: false),
            ]
        ).trimmingCharacters(in: .whitespacesAndNewlines)

        #expect(iconName == "QuickTodo.icns")
    }

    private func repoRoot(filePath: StaticString = #filePath) throws -> URL {
        URL(fileURLWithPath: "\(filePath)")
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @discardableResult
    private func run(
        _ executable: String,
        arguments: [String],
        currentDirectoryURL: URL? = nil
    ) throws -> String {
        let logURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("log")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.currentDirectoryURL = currentDirectoryURL
        FileManager.default.createFile(atPath: logURL.path(percentEncoded: false), contents: Data())
        let logHandle = try FileHandle(forWritingTo: logURL)
        process.standardOutput = logHandle
        process.standardError = logHandle

        try process.run()
        process.waitUntilExit()
        try logHandle.close()

        let output = try String(contentsOf: logURL, encoding: .utf8)
        try? FileManager.default.removeItem(at: logURL)

        #expect(
            process.terminationStatus == 0,
            Comment(rawValue: """
            Command failed: \(executable) \(arguments.joined(separator: " "))
            \(output)
            """)
        )

        return output
    }
}
