import Testing
@testable import QuickTodo

@MainActor
struct AppVersionDisplayTests {
    @Test
    func versionBadgeTextUsesShortVersionWhenAvailable() {
        #expect(AppModel.versionBadgeText(shortVersion: "0.1.9", build: "12") == "v0.1.9")
    }

    @Test
    func versionBadgeTextFallsBackToBuildWhenShortVersionIsPlaceholder() {
        #expect(AppModel.versionBadgeText(shortVersion: "__VERSION__", build: "12") == "v12")
    }

    @Test
    func versionBadgeTextFallsBackToDevWhenNoUsableVersionExists() {
        #expect(AppModel.versionBadgeText(shortVersion: nil, build: "__BUILD__") == "vdev")
    }
}
