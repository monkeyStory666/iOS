// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public struct RightToLeftLanguageDetector: RightToLeftLanguageDetecting {
    public func isRightToLeftLanguage() -> Bool {
        guard let languageIdentifier = Locale.autoupdatingCurrent.languageCode else {
            return false
        }

        let layoutDirection = Locale.characterDirection(forLanguage: languageIdentifier)
        return layoutDirection == .rightToLeft
    }
}
