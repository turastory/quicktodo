import AppKit
import SwiftUI

enum QuickTodoTheme {
    static let canvasNSColor = dynamicColor(
        light: NSColor(calibratedRed: 0.96, green: 0.96, blue: 0.95, alpha: 1),
        dark: NSColor(calibratedRed: 0.10, green: 0.11, blue: 0.12, alpha: 1)
    )

    static let chromeNSColor = dynamicColor(
        light: NSColor(calibratedRed: 0.92, green: 0.92, blue: 0.91, alpha: 0.96),
        dark: NSColor(calibratedRed: 0.14, green: 0.15, blue: 0.16, alpha: 0.96)
    )

    static let lineNSColor = dynamicColor(
        light: NSColor(calibratedWhite: 0, alpha: 0.08),
        dark: NSColor(calibratedWhite: 1, alpha: 0.09)
    )

    static let accentNSColor = NSColor(calibratedRed: 0.45, green: 0.77, blue: 0.69, alpha: 1)
    static let warmAccentNSColor = NSColor(calibratedRed: 0.86, green: 0.58, blue: 0.36, alpha: 1)
    static let linkNSColor = dynamicColor(
        light: NSColor(calibratedRed: 0.17, green: 0.43, blue: 0.78, alpha: 1),
        dark: NSColor(calibratedRed: 0.53, green: 0.77, blue: 0.98, alpha: 1)
    )
    static let syntaxSecondaryNSColor = dynamicColor(
        light: NSColor(calibratedRed: 0.43, green: 0.47, blue: 0.50, alpha: 1),
        dark: NSColor(calibratedRed: 0.62, green: 0.66, blue: 0.70, alpha: 1)
    )

    static let canvas = Color(nsColor: canvasNSColor)
    static let chrome = Color(nsColor: chromeNSColor)
    static let line = Color(nsColor: lineNSColor)

    static let primaryText = Color(nsColor: NSColor.labelColor)
    static let secondaryText = Color(nsColor: NSColor.secondaryLabelColor)
    static let accent = Color(nsColor: accentNSColor)
    static let warmAccent = Color(nsColor: warmAccentNSColor)
    static let danger = Color(nsColor: NSColor.systemRed.withAlphaComponent(0.9))

    private static func dynamicColor(light: NSColor, dark: NSColor) -> NSColor {
        NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return dark
            }

            return light
        }
    }
}
