// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import Testing

struct FileSystemRepositoryTests {
    @Test func documentsDirectory_shouldMatch() {
        let sut = makeSUT()

        #expect(sut.documentsDirectory() == documentDirectory())
    }

    @Test func temporaryDirectory_shouldMatch() {
        let sut = makeSUT()
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())

        #expect(sut.temporaryDirectory() == temporaryDirectory)
    }

    @Test func applicationSupportDirectory_shouldMatch() {
        let sut = makeSUT()
        let temporaryDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        )[0])

        #expect(sut.applicationSupportDirectory() == temporaryDirectory)
    }

    @Test func cacheDirectory_shouldMatch() {
        let sut = makeSUT()
        let cacheDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(
            .cachesDirectory, .userDomainMask, true
        )[0])

        #expect(sut.cacheDirectory() == cacheDirectory)
    }

    @Test func fileExists_removeFile() {
        let sut = makeSUT()
        let filePath = documentDirectory().appendingPathComponent(String.random())
        #expect(sut.fileExists(at: filePath) == false)

        FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        #expect(sut.fileExists(at: filePath) == true)

        sut.removeFile(at: filePath)
        #expect(sut.fileExists(at: filePath) == false)
    }

    @Test func containerURLForSecurityApplicationGroupIdentifier_shouldMatch() {
        let sut = makeSUT()

        #expect(
            sut.containerURL(
                forSecurityApplicationGroupIdentifier: "group.identifier"
            ) == FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.identifier"
            )
        )
    }

    @Test func removeContentsOfDirectory_shouldRemoveAllFiles() throws {
        let sut = makeSUT()
        let directory = documentDirectory().appendingPathComponent(String.random())
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

        let file1 = directory.appendingPathComponent(String.random())
        let file2 = directory.appendingPathComponent(String.random())
        FileManager.default.createFile(atPath: file1.path, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: file2.path, contents: nil, attributes: nil)

        #expect(sut.fileExists(at: file1) == true)
        #expect(sut.fileExists(at: file2) == true)

        sut.removeContentsOfDirectory(atPath: directory)

        #expect(sut.fileExists(at: file1) == false)
        #expect(sut.fileExists(at: file2) == false)
    }

    // MARK: - Helpers

    private func makeSUT(
        fileManager: FileManager = .default
    ) -> some FileSystemRepositoryProtocol {
        FileSystemRepository(fileManager: fileManager)
    }

    private func documentDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
