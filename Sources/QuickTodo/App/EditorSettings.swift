import AppKit
import Foundation

struct EditorSettings: Equatable {
    static let defaultFontSize = 15.0

    var fontName: String
    var fontSize: Double

    init(
        fontName: String,
        fontSize: Double = Self.defaultFontSize,
        fontLibrary: EditorFontLibrary = EditorFontLibrary()
    ) {
        self.fontName = fontLibrary.resolvedFontName(fontName)
        self.fontSize = Self.sanitized(fontSize)
    }

    static func load(
        fontName: String?,
        fontSize: Double?,
        fontLibrary: EditorFontLibrary = EditorFontLibrary()
    ) -> EditorSettings {
        let resolvedFontName = fontLibrary.resolvedFontName(fontName)
        let fontSize = fontSize ?? defaultFontSize
        return EditorSettings(fontName: resolvedFontName, fontSize: fontSize, fontLibrary: fontLibrary)
    }

    static func sanitized(_ fontSize: Double) -> Double {
        guard fontSize.isFinite, fontSize > 0 else {
            return defaultFontSize
        }

        return fontSize
    }

    var editorFont: NSFont {
        resolvedRegularFont(ofSize: CGFloat(fontSize))
    }

    var emphasizedFont: NSFont {
        let baseFont = resolvedRegularFont(ofSize: CGFloat(fontSize))
        let boldFont = NSFontManager.shared.convert(baseFont, toHaveTrait: .boldFontMask)
        if boldFont.pointSize > 0 {
            return boldFont
        }

        return NSFont.systemFont(ofSize: CGFloat(fontSize), weight: .semibold)
    }

    private func resolvedRegularFont(ofSize size: CGFloat) -> NSFont {
        NSFont(name: fontName, size: size) ??
            NSFontManager.shared.font(withFamily: fontName, traits: [], weight: 5, size: size) ??
            NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }
}
