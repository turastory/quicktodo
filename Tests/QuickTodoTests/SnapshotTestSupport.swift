import AppKit
import Foundation
import SwiftUI
import Testing
@testable import QuickTodo

@MainActor
enum SnapshotTestSupport {
    static func renderedPixelSize<Content: View>(
        for rootView: Content,
        size: NSSize
    ) throws -> NSSize {
        let bitmap = try renderBitmap(
            for: rootView,
            size: size
        )

        return NSSize(
            width: bitmap.pixelsWide,
            height: bitmap.pixelsHigh
        )
    }

    static func assertSnapshot<Content: View>(
        named snapshotName: String,
        size: NSSize,
        rootView: Content,
        filePath: StaticString = #filePath
    ) throws {
        let snapshotURL = snapshotFileURL(
            filePath: filePath,
            snapshotName: snapshotName
        )
        let renderedImage = try renderImage(
            for: rootView,
            size: size
        )

        if ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1" {
            try writePNG(renderedImage, to: snapshotURL)
            return
        }

        guard FileManager.default.fileExists(atPath: snapshotURL.path) else {
            throw SnapshotError.missingReference(snapshotURL.path(percentEncoded: false))
        }

        let referenceImage = try loadImage(from: snapshotURL)
        let renderedPixels = try normalizedPixelBuffer(from: renderedImage)
        let referencePixels = try normalizedPixelBuffer(from: referenceImage)

        guard renderedPixels == referencePixels else {
            let failureURL = snapshotURL.deletingPathExtension()
                .appendingPathExtension("failed.png")
            try writePNG(renderedImage, to: failureURL)
            throw SnapshotError.mismatch(
                referencePath: snapshotURL.path(percentEncoded: false),
                failurePath: failureURL.path(percentEncoded: false)
            )
        }
    }

    private static func snapshotFileURL(
        filePath: StaticString,
        snapshotName: String
    ) -> URL {
        let testFileURL = URL(fileURLWithPath: "\(filePath)")
        let snapshotsDirectory = testFileURL.deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
        return snapshotsDirectory.appendingPathComponent("\(snapshotName).png")
    }

    private static func renderImage<Content: View>(
        for rootView: Content,
        size: NSSize
    ) throws -> NSImage {
        let bitmap = try renderBitmap(
            for: rootView,
            size: size
        )
        let image = NSImage(size: size)
        image.addRepresentation(bitmap)
        return image
    }

    private static func renderBitmap<Content: View>(
        for rootView: Content,
        size: NSSize
    ) throws -> NSBitmapImageRep {
        _ = NSApplication.shared

        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(origin: .zero, size: size)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.appearance = NSAppearance(named: .aqua)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .aqua)
        window.contentView = hostingView
        window.layoutIfNeeded()
        hostingView.layoutSubtreeIfNeeded()
        hostingView.displayIfNeeded()

        guard
            let bitmap = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(size.width),
                pixelsHigh: Int(size.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: 0,
                bitsPerPixel: 0
            )
        else {
            throw SnapshotError.renderFailure("Unable to allocate snapshot bitmap")
        }

        bitmap.size = size
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmap)
        window.close()
        return bitmap
    }

    private static func loadImage(from url: URL) throws -> NSImage {
        guard let image = NSImage(contentsOf: url) else {
            throw SnapshotError.renderFailure("Unable to load snapshot at \(url.path(percentEncoded: false))")
        }

        return image
    }

    private static func writePNG(_ image: NSImage, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        guard
            let tiffData = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData),
            let pngData = bitmap.representation(using: .png, properties: [:])
        else {
            throw SnapshotError.renderFailure("Unable to encode PNG for \(url.lastPathComponent)")
        }

        try pngData.write(to: url)
    }

    private static func normalizedPixelBuffer(from image: NSImage) throws -> PixelBuffer {
        var proposedRect = NSRect(origin: .zero, size: image.size)

        guard let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) else {
            throw SnapshotError.renderFailure("Unable to build CGImage from rendered snapshot")
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        var data = Data(count: height * bytesPerRow)

        let rendered = data.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else {
                return false
            }

            guard let context = CGContext(
                data: baseAddress,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }

            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }

        guard rendered else {
            throw SnapshotError.renderFailure("Unable to normalize snapshot pixel buffer")
        }

        return PixelBuffer(width: width, height: height, rgba: data)
    }
}

private struct PixelBuffer: Equatable {
    let width: Int
    let height: Int
    let rgba: Data
}

private enum SnapshotError: Error, CustomStringConvertible {
    case missingReference(String)
    case mismatch(referencePath: String, failurePath: String)
    case renderFailure(String)

    var description: String {
        switch self {
        case let .missingReference(path):
            return "참조 스냅샷이 없습니다: \(path)\n`RECORD_SNAPSHOTS=1 swift test --filter ScreenSnapshotTests` 로 먼저 기록해 주세요."
        case let .mismatch(referencePath, failurePath):
            return "스냅샷이 달라졌습니다.\n기준: \(referencePath)\n실패 출력: \(failurePath)"
        case let .renderFailure(message):
            return "스냅샷 렌더링에 실패했습니다: \(message)"
        }
    }
}
