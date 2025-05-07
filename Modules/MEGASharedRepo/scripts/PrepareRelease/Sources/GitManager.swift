import Foundation
import SharedReleaseScript

struct GitManager {
    enum GitManagerError: Error {
        case prepareBranchNotExists
    }

    private let version: String
    private let directoryManager: DirectoryManager
    private var prepareBranch: String?

    init(version: String, directoryManager: DirectoryManager = DirectoryManager()) {
        self.version = version
        self.directoryManager = directoryManager
    }

    mutating func createPrepareBranch() throws {
        try runInShell("git checkout develop")
        try runInShell("git pull")
        let prepareBranch = "task/prepare-\(version)"
        try runInShell("git checkout -b \(prepareBranch)")
        self.prepareBranch = prepareBranch
    }

    func setVersionNumber() throws {
        let pathToPBXProj = try directoryManager.projectFileName()
        try updateProjectVersion(version, pathToPBXProj: "\(pathToPBXProj)/project.pbxproj")
    }

    func updateSubmodules(sdkCommitHash: String, chatSDKCommitHash: String?) throws {
        try runInShell("git submodule foreach 'git fetch origin'")
        try updateSubmodule(withPath: try Submodule.sdk.path, commitHash: sdkCommitHash)
        if let chatSDKCommitHash {
            try updateSubmodule(withPath: try Submodule.chatSDK.path, commitHash: chatSDKCommitHash)
        }
    }

    func commitChanges() throws {
        try runInShell("git add .")
        try runInShell("git commit -m \"Prepare v\(version)\"")
    }

    func createMR() throws {
        guard let prepareBranch else {
            throw GitManagerError.prepareBranchNotExists
        }

        try createMRUsingGitCommand(
            sourceBranch: prepareBranch,
            targetBranch: "develop",
            title: "Prepare v\(version)",
            squash: true
        )
    }

    private func updateSubmodule(withPath submodulePath: String, commitHash: String) throws {
        try runInShell("git submodule update --init", cwd: URL(fileURLWithPath: submodulePath))
        try runInShell("git checkout \(commitHash)", cwd: URL(fileURLWithPath: submodulePath))
    }
}
