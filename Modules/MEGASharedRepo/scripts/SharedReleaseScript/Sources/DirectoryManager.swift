import Foundation

public struct DirectoryManager {
    public enum DirectoryManagerError: Error {
        case failedToChangeDirectory
        case noXcodeprojFileFound
    }

    private let fileManager: FileManager

    public var currentDirectoryPath: String { fileManager.currentDirectoryPath }

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func change(to directory: String) throws {
        guard fileManager.changeCurrentDirectoryPath(directory) else {
            throw DirectoryManagerError.failedToChangeDirectory
        }
    }

    public func fileExists(atPath path: String) -> Bool {
        fileManager.fileExists(atPath: path)
    }

    public func executeInProjectRoot(_ block: () throws -> Void) throws {
        let tempCurrentDirectory = currentDirectoryPath
        try change(to: try projectFileDirectory())
        try block()
        try change(to: tempCurrentDirectory)
    }

    public func asyncExecuteInProjectRoot(_ block: () async throws -> Void) async throws {
        let tempCurrentDirectory = currentDirectoryPath
        try change(to: try projectFileDirectory())
        try await block()
        try change(to: tempCurrentDirectory)
    }

    public func projectFileDirectory() throws -> String {
        var currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        var xcodeprojFound = false

        while !xcodeprojFound {
            if try fileManager
                .contentsOfDirectory(atPath: currentDirectory.path)
                .lazy
                .contains(where: { $0.hasSuffix(".xcodeproj") }) {
                xcodeprojFound = true
            } else if currentDirectory.path == "/" {
                throw DirectoryManagerError.noXcodeprojFileFound
            } else {
                currentDirectory = currentDirectory.deletingLastPathComponent()
            }
        }

        return currentDirectory.path
    }

    public func projectFileName() throws -> String {
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let contents = try fileManager.contentsOfDirectory(atPath: currentDirectory.path)
        if let projectFile = contents.first(where: { $0.hasSuffix(".xcodeproj") }) {
            return projectFile
        } else {
            throw DirectoryManagerError.noXcodeprojFileFound
        }
    }
}
