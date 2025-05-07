// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation

public protocol FileSystemRepositoryProtocol {
    func documentsDirectory() -> URL
    func cacheDirectory() -> URL
    func temporaryDirectory() -> URL
    func applicationSupportDirectory() -> URL
    func fileExists(at url: URL) -> Bool
    func removeFile(at url: URL)
    func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL?
    func removeContentsOfDirectory(atPath directoryPath: URL)
}

public struct FileSystemRepository: FileSystemRepositoryProtocol {
    private let fileManager: FileManager

    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    public func documentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    public func cacheDirectory() -> URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    public func temporaryDirectory() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
    }

    public func applicationSupportDirectory() -> URL {
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        )[0]
        return URL(fileURLWithPath: applicationSupportDirectory)
    }

    public func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }

    public func removeFile(at url: URL) {
        try? fileManager.removeItem(at: url)
    }

    public func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }

    public func removeContentsOfDirectory(atPath directoryPath: URL) {
        try? fileManager.contentsOfDirectory(atPath: directoryPath.path).forEach { subDirectory  in
            let subDirectoryPath = directoryPath.appendingPathComponent(subDirectory)
            try? fileManager.removeItem(atPath: subDirectoryPath.path)
        }
    }
}
