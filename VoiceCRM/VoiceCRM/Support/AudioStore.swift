import Foundation

enum AudioStore {
    static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appending(path: "Audio", directoryHint: .isDirectory)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    static func url(for fileName: String) -> URL { directory.appending(path: fileName) }
    static func newFileName() -> String { UUID().uuidString + ".m4a" }
    static func delete(fileName: String) { try? FileManager.default.removeItem(at: url(for: fileName)) }
}
