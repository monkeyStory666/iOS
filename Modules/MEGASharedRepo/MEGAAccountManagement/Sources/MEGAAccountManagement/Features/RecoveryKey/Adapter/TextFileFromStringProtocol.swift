// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol TextFileFromStringProtocol {
    func textFile(from string: String) -> URL?
}

struct TextFileFromString: TextFileFromStringProtocol {
    func textFile(from string: String) -> URL? {
        guard let textData = string.data(using: .utf8) else { return nil }

        let textFileURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(Constants.recoveryKeyFileName)

        do {
            try textData.write(to: textFileURL)
            return textFileURL
        } catch {
            return nil
        }
    }
}
