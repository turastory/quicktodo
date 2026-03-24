import Dispatch
import Foundation

final class DirectoryMonitor {
    private let url: URL
    private let handler: () -> Void
    private let queue = DispatchQueue(label: "QuickTodo.DirectoryMonitor")

    private var fileDescriptor: CInt = -1
    private var source: DispatchSourceFileSystemObject?

    init(url: URL, handler: @escaping () -> Void) {
        self.url = url
        self.handler = handler
    }

    deinit {
        stop()
    }

    func start() throws {
        guard source == nil else {
            return
        }

        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            throw CocoaError(.fileNoSuchFile)
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete, .attrib, .extend, .link, .revoke],
            queue: queue
        )

        source.setEventHandler(handler: handler)
        source.setCancelHandler { [weak self] in
            guard let self else {
                return
            }

            if self.fileDescriptor >= 0 {
                close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }

        self.source = source
        source.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }
}
