import ArgumentParser
import Foundation
import SharedReleaseScript

@main
struct PrepareRelease: AsyncParsableCommand {

    @Option(help: "Version number for the release")
    var versionNumber: String

    @Option(help: "SDK commit hash")
    var sdkCommitHash: String

    @Option(help: "Chat SDK commit hash")
    var chatSDKCommitHash: String?

    func run() async throws {
        let directoryManager = DirectoryManager()
        var gitManager = GitManager(version: versionNumber)

        try directoryManager.executeInProjectRoot {
            print("Step 1: Creating prepare branch...")
            try gitManager.createPrepareBranch()

            print("Step 2: Pruning and downloading strings from Transifex...")
            try pruneAndDownloadStringFromTransifex()

            print("Step 3: Setting version number...")
            try gitManager.setVersionNumber()

            print("Step 4: Updating submodules with preferred SDK commit and ChatSDK commit...")
            try gitManager.updateSubmodules(sdkCommitHash: sdkCommitHash, chatSDKCommitHash: chatSDKCommitHash)

            print("Step 5: Committing changes...")
            try gitManager.commitChanges()

            print("Step 6: Creating merge request...")
            try gitManager.createMR()
        }
    }

    private func pruneAndDownloadStringFromTransifex() throws {
        let transifexManager = TransifexManager()
        try transifexManager.prune()
        try transifexManager.downloadedStrings()
    }
}
