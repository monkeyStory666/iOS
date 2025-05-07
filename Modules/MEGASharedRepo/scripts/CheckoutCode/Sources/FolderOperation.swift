import Foundation

struct FolderOperation {
    private let fileManager = FileManager.default

    var currentDirectoryPath: String {
        fileManager.currentDirectoryPath
    }

    func copyFile(from path: String, to destinationFolder: String) throws {
        let sourceURL = URL(fileURLWithPath: path)
        let destinationURL = URL(fileURLWithPath: destinationFolder).appendingPathComponent(sourceURL.lastPathComponent)

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }

    func removeFolder(at path: String) throws {
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(at: URL(fileURLWithPath: path))
            print("Folder and its contents removed successfully.")
        } else {
            print("Folder does not exist.")
        }
    }

    func createFolderIfNeeded(at path: String) {
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                print("Folder created at: \(path)")
            } catch {
                print("Error creating folder: \(error)")
            }
        } else {
            print("Folder already exists at: \(path)")
        }
    }

    func updateFiles(with fileName: String, in directory: String, from oldText: String, to newText: String) {
        do {
            let subfolders = try fileManager.contentsOfDirectory(atPath: directory)
                .filter { URL(fileURLWithPath: directory).appendingPathComponent($0).hasDirectoryPath }

            print("subfolders found: \(subfolders)")

            for subfolder in subfolders {
                let filePath = "\(directory)/\(subfolder)/\(fileName)"

                print("subfolder file path: \(filePath)")

                if fileManager.fileExists(atPath: filePath) {
                    do {
                        let content = try String(contentsOfFile: filePath, encoding: .utf8)
                        let updatedContent = content.replacingOccurrences(of: oldText, with: newText)

                        if content != updatedContent {
                            try updatedContent.write(toFile: filePath, atomically: true, encoding: .utf8)
                            print("Updated \(filePath)")
                        } else {
                            print("No changes needed in \(filePath)")
                        }
                    } catch {
                        print("Failed to update \(filePath): \(error)")
                    }
                }
            }
        } catch {
            print("Error reading directory: \(error)")
        }
    }
}
