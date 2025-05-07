// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public extension URL {
    static var random: URL { URL(fileURLWithPath: "/testFilePath/\(Int.random())/fileName.fileExtension")}
}
