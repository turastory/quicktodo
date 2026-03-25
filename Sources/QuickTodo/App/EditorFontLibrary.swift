import AppKit
import Foundation

struct EditorFontSection: Equatable {
    let title: String
    let fontNames: [String]
}

struct EditorFontLibrary {
    static let defaultRecommendedFontNames = [
        "Monaspace Neon",
        "SF Mono",
        "Menlo",
        "Avenir Next",
        "Charter",
    ]

    let allFontNames: [String]
    let recommendedFontNames: [String]

    init(
        allFontNames: [String] = NSFontManager.shared.availableFontFamilies,
        recommendedFontNames: [String] = Self.defaultRecommendedFontNames
    ) {
        self.allFontNames = Self.sortedUniqueFontNames(allFontNames)
        self.recommendedFontNames = Self.stableUniqueFontNames(recommendedFontNames)
    }

    var defaultFontName: String {
        recommendedFontNames.first(where: isAvailable) ??
            allFontNames.first ??
            "SF Mono"
    }

    func isAvailable(_ fontName: String) -> Bool {
        allFontNames.contains(fontName)
    }

    func resolvedFontName(_ fontName: String?) -> String {
        guard let fontName, isAvailable(fontName) else {
            return defaultFontName
        }

        return fontName
    }

    func sections(searchText: String, recentFontNames: [String]) -> [EditorFontSection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let recentFonts = recentFontNames
            .filter(isAvailable)
            .filter { matchesSearch($0, query: query) }
        let recentSet = Set(recentFonts)

        let recommendedFonts = recommendedFontNames
            .filter(isAvailable)
            .filter { recentSet.contains($0) == false }
            .filter { matchesSearch($0, query: query) }
        let recommendedSet = Set(recommendedFonts)

        let otherFonts = allFontNames
            .filter { recentSet.contains($0) == false }
            .filter { recommendedSet.contains($0) == false }
            .filter { matchesSearch($0, query: query) }

        return [
            EditorFontSection(title: "Recent", fontNames: recentFonts),
            EditorFontSection(title: "Recommended", fontNames: recommendedFonts),
            EditorFontSection(title: "All Fonts", fontNames: otherFonts),
        ]
        .filter { $0.fontNames.isEmpty == false }
    }

    func updatedRecentFontNames(byAdding fontName: String, to existing: [String], limit: Int = 6) -> [String] {
        guard isAvailable(fontName) else {
            return existing.filter(isAvailable).prefix(limit).map(\.self)
        }

        let dedupedExisting = existing.filter(isAvailable).filter { $0 != fontName }
        return ([fontName] + dedupedExisting).prefix(limit).map(\.self)
    }

    private func matchesSearch(_ fontName: String, query: String) -> Bool {
        guard query.isEmpty == false else {
            return true
        }

        return fontName.localizedCaseInsensitiveContains(query)
    }

    private static func stableUniqueFontNames(_ fontNames: [String]) -> [String] {
        var seen = Set<String>()

        return fontNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
    }

    private static func sortedUniqueFontNames(_ fontNames: [String]) -> [String] {
        stableUniqueFontNames(fontNames)
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
}
