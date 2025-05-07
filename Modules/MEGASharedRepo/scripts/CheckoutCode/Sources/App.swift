import ArgumentParser
import Foundation

@main
struct CheckoutCode: ParsableCommand {
    @Option(help: "URL string to checkout the code")
    var projectURLString: String

    @Option(help: "branch to checkout")
    var checkoutBranch: String

    @Option(help: "Checkout the code at the given path")
    var path: String

    @Option(help: "URL string for the host application")
    var hostAppProjectURLString: String

    @Option(help: "Checkout branch for the host application")
    var hostAppCheckoutBranch: String

    @Option(help: "Swift package file path for SDK in the host application")
    var sdkSPMFilePathInHostApp: String

    mutating func run() throws {
        let folderOperation = FolderOperation()
        folderOperation.createFolderIfNeeded(at: path)
        try fetchSwiftPackageFile(folderOperation: folderOperation)
        try checkout(projectURLString: projectURLString, checkoutBranch: checkoutBranch, path: path)
        changeSDKPathToRoot(folderOperation: folderOperation)
    }

    private func changeSDKPathToRoot(folderOperation: FolderOperation) {
        let rootFolder = URL(fileURLWithPath: folderOperation.currentDirectoryPath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path
        folderOperation.updateFiles(
            with: "Package.swift",
            in: rootFolder,
            from: ".package(path: \"../../DataSource/MEGASDK\")",
            to: ".package(path: \"../DataSource/MEGASDK\")"
        )
    }

    private func copyPackageFile(folderOperation: FolderOperation, sourceFileWithPath: String) throws {
        let destinationFolder = URL(fileURLWithPath: path)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path
        try folderOperation.copyFile(from: sourceFileWithPath, to: destinationFolder)
    }

    private func fetchSwiftPackageFile(folderOperation: FolderOperation) throws {
        let hostAPPDownloadPath = "\(path)/hostApp"
        try checkout(projectURLString: hostAppProjectURLString, checkoutBranch: hostAppCheckoutBranch, path: hostAPPDownloadPath)
        let sourceFileWithPath = "\(hostAPPDownloadPath)/\(sdkSPMFilePathInHostApp)/Package.swift"
        try copyPackageFile(folderOperation: folderOperation, sourceFileWithPath: sourceFileWithPath)
        try folderOperation.removeFolder(at: hostAPPDownloadPath)
    }

    private func checkout(projectURLString: String, checkoutBranch: String, path: String) throws {
        print("cloning remote \(projectURLString) - \(checkoutBranch) branch")
        try runInShell("git clone \(projectURLString) -b \(checkoutBranch) \(path)")
        print("Success cloning remote \(projectURLString) - \(checkoutBranch) branch")
    }
}
