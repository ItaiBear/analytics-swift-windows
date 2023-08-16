
#if os(Windows)

import Foundation

class NSCoderHelpers {

    /// Path to directory to store user data.
    static var userDataDirectory: URL = {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("L1 - Angles", isDirectory: true).appendingPathComponent("User Data", isDirectory: true)

        if !FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            } catch {
                Analytics.segmentLog(message: "file error: \(error)", kind: .error)
            }
        }

        return path
    }()

    static var segmentDirectory: URL = {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("L1 - Angles", isDirectory: true).appendingPathComponent("Segment", isDirectory: true)

        if !FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            } catch {
                Analytics.segmentLog(message: "file error: \(error)", kind: .error)
            }
        }

        return path
    }()

}

#endif
