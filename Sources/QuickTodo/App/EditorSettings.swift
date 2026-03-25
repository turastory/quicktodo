import AppKit
import Foundation

enum EditorFontChoice: String, CaseIterable, Identifiable {
    case monaspaceNeon
    case sfMono
    case menlo
    case avenirNext
    case charter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .monaspaceNeon:
            return "Monaspace Neon"
        case .sfMono:
            return "SF Mono"
        case .menlo:
            return "Menlo"
        case .avenirNext:
            return "Avenir Next"
        case .charter:
            return "Charter"
        }
    }

    fileprivate func regularFont(ofSize size: CGFloat) -> NSFont {
        switch self {
        case .monaspaceNeon:
            return NSFont(name: "Monaspace Neon", size: size) ??
                NSFont(name: "MonaspaceNeon-Regular", size: size) ??
                NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case .sfMono:
            return NSFont(name: "SF Mono", size: size) ??
                NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case .menlo:
            return NSFont(name: "Menlo", size: size) ??
                NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        case .avenirNext:
            return NSFont(name: "Avenir Next", size: size) ??
                NSFont.systemFont(ofSize: size, weight: .regular)
        case .charter:
            return NSFont(name: "Charter", size: size) ??
                NSFont.systemFont(ofSize: size, weight: .regular)
        }
    }

    fileprivate func emphasizedFont(ofSize size: CGFloat) -> NSFont {
        let baseFont = regularFont(ofSize: size)
        let boldFont = NSFontManager.shared.convert(baseFont, toHaveTrait: .boldFontMask)
        if boldFont.pointSize > 0 {
            return boldFont
        }

        switch self {
        case .avenirNext, .charter:
            return NSFont.systemFont(ofSize: size, weight: .semibold)
        default:
            return NSFont.monospacedSystemFont(ofSize: size, weight: .semibold)
        }
    }
}

struct EditorSettings: Equatable {
    static let defaultFontSize = 15.0

    var fontChoice: EditorFontChoice
    var fontSize: Double

    init(
        fontChoice: EditorFontChoice = .monaspaceNeon,
        fontSize: Double = Self.defaultFontSize
    ) {
        self.fontChoice = fontChoice
        self.fontSize = Self.sanitized(fontSize)
    }

    static func load(
        fontChoiceRawValue: String?,
        fontSize: Double?
    ) -> EditorSettings {
        let fontChoice = fontChoiceRawValue.flatMap(EditorFontChoice.init(rawValue:)) ?? .monaspaceNeon
        let fontSize = fontSize ?? defaultFontSize
        return EditorSettings(fontChoice: fontChoice, fontSize: fontSize)
    }

    static func sanitized(_ fontSize: Double) -> Double {
        guard fontSize.isFinite, fontSize > 0 else {
            return defaultFontSize
        }

        return fontSize
    }

    var editorFont: NSFont {
        fontChoice.regularFont(ofSize: CGFloat(fontSize))
    }

    var emphasizedFont: NSFont {
        fontChoice.emphasizedFont(ofSize: CGFloat(fontSize))
    }
}
