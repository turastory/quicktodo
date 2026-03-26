import Foundation

struct LaunchPresentationPolicy {
    static func shouldShowPanelOnLaunch(selectedFilePath: String?) -> Bool {
        selectedFilePath == nil
    }
}
