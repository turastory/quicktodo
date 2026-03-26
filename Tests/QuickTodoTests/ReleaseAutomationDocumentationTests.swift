import Foundation
import Testing

struct ReleaseAutomationDocumentationTests {
    @Test
    func releaseWorkflowDispatchesTapUpdatesWithoutNotarizationGate() throws {
        let workflow = try loadFile(".github/workflows/release.yml")

        #expect(workflow.contains("name: Dispatch tap cask update"))
        #expect(!workflow.contains("steps.release_mode.outputs.notarized == '1'"))
        #expect(!workflow.contains("Skip tap dispatch when notarization is unavailable"))
    }

    @Test
    func readmeDocumentsTapInstallUpgradeAndRemovalCommands() throws {
        let readme = try loadFile("README.md")

        #expect(readme.contains("brew tap turastory/tap"))
        #expect(readme.contains("brew install --cask quicktodo"))
        #expect(readme.contains("brew update && brew upgrade --cask quicktodo"))
        #expect(readme.contains("brew uninstall --cask quicktodo"))
        #expect(readme.contains("Gatekeeper"))
    }

    private func loadFile(_ relativePath: String, filePath: StaticString = #filePath) throws -> String {
        let rootDirectory = URL(fileURLWithPath: "\(filePath)")
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        return try String(
            contentsOf: rootDirectory.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }
}
