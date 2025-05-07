// Copyright © 2023 MEGA Limited. All rights reserved.

import UIKit

public typealias ColorHexCode = String

public protocol DefaultAvatarGenerating {
    func generate(
        initials: String,
        backgroundColor: ColorHexCode,
        secondaryBackgroundColor: ColorHexCode,
        isRightToLeftLanguage: Bool
    ) async throws -> UIImage
}
