import Foundation

struct FileFingerprint: Equatable {
    let modificationDate: Date
    let fileSize: Int64
}

struct MarkdownDocument {
    let content: String
    let fingerprint: FileFingerprint
}

enum MarkdownDocumentStoreError: LocalizedError {
    case fileMissing(URL)
    case parentDirectoryMissing(URL)
    case readFailed(URL, Error)
    case writeFailed(URL, Error)
    case downloadTimedOut(URL)

    var errorDescription: String? {
        switch self {
        case let .fileMissing(url):
            return "'\(url.lastPathComponent)' 파일을 찾을 수 없습니다."
        case let .parentDirectoryMissing(url):
            return "'\(url.lastPathComponent)' 상위 폴더를 찾을 수 없습니다."
        case let .readFailed(url, error):
            return "'\(url.lastPathComponent)' 파일을 읽지 못했습니다: \(error.localizedDescription)"
        case let .writeFailed(url, error):
            return "'\(url.lastPathComponent)' 파일에 저장하지 못했습니다: \(error.localizedDescription)"
        case let .downloadTimedOut(url):
            return "'\(url.lastPathComponent)' iCloud 다운로드가 끝나지 않았습니다."
        }
    }
}

struct MarkdownDocumentStore {
    func prepareForAccess(at url: URL) async throws -> URL {
        try await ensureLocalAvailability(at: url)
        return url
    }

    func read(from url: URL) throws -> MarkdownDocument {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw MarkdownDocumentStoreError.fileMissing(url)
        }

        do {
            let data = try Data(contentsOf: url)
            let content = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
            return MarkdownDocument(content: content, fingerprint: try makeFingerprint(for: url))
        } catch {
            throw MarkdownDocumentStoreError.readFailed(url, error)
        }
    }

    func write(content: String, to url: URL) throws -> MarkdownDocument {
        let parentDirectory = url.deletingLastPathComponent()
        guard FileManager.default.fileExists(atPath: parentDirectory.path) else {
            throw MarkdownDocumentStoreError.parentDirectoryMissing(parentDirectory)
        }

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return try read(from: url)
        } catch {
            throw MarkdownDocumentStoreError.writeFailed(url, error)
        }
    }

    private func makeFingerprint(for url: URL) throws -> FileFingerprint {
        let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
        return FileFingerprint(
            modificationDate: values.contentModificationDate ?? .distantPast,
            fileSize: Int64(values.fileSize ?? 0)
        )
    }

    private func ensureLocalAvailability(at url: URL) async throws {
        let keys: Set<URLResourceKey> = [
            .isUbiquitousItemKey,
            .ubiquitousItemDownloadingStatusKey,
        ]

        let values = try url.resourceValues(forKeys: keys)
        guard values.isUbiquitousItem == true else {
            return
        }

        let status = values.ubiquitousItemDownloadingStatus
        if status == URLUbiquitousItemDownloadingStatus.current {
            return
        }

        try FileManager.default.startDownloadingUbiquitousItem(at: url)

        for _ in 0..<60 {
            try await Task.sleep(for: .milliseconds(250))
            let updatedValues = try url.resourceValues(forKeys: keys)

            if updatedValues.ubiquitousItemDownloadingStatus == URLUbiquitousItemDownloadingStatus.current ||
                FileManager.default.isReadableFile(atPath: url.path) {
                return
            }
        }

        throw MarkdownDocumentStoreError.downloadTimedOut(url)
    }
}
