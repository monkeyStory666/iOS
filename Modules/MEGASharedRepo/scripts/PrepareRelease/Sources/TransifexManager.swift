import Foundation
import SharedReleaseScript

struct TransifexManager {
    enum TransifexManagerError: Error {
        case pruneScriptDoesNotExists
    }

    private let directoryManager: DirectoryManager
    private let scriptFileWithPath: String

    init(
        directoryManager: DirectoryManager = DirectoryManager(),
        scriptFileWithPath: String = "./scripts/prune-strings.sh"
    ) {
        self.directoryManager = directoryManager
        self.scriptFileWithPath = scriptFileWithPath
    }

    func prune() throws {
        guard directoryManager.fileExists(atPath: scriptFileWithPath) else {
            throw TransifexManagerError.pruneScriptDoesNotExists
        }

        try runInShell(scriptFileWithPath)
    }

    func downloadedStrings() throws {
        try runInShell("./iosTransifex/iosTransifex.py -m export")
    }
}
