import Testing
@testable import QuickTodo

struct LaunchPresentationPolicyTests {
    @Test
    func showsPanelWhenNoSelectedFilePathIsStored() {
        #expect(LaunchPresentationPolicy.shouldShowPanelOnLaunch(selectedFilePath: nil))
    }

    @Test
    func doesNotShowPanelWhenSelectedFilePathExists() {
        #expect(
            !LaunchPresentationPolicy.shouldShowPanelOnLaunch(
                selectedFilePath: "/Users/test/Obsidian/Todo.md"
            )
        )
    }
}
