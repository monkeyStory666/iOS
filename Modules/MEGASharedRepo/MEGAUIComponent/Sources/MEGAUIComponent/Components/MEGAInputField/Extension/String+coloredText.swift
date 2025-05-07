// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGADesignToken
import UIKit

public extension String {
    var coloredText: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        let customFont = UIFont(name: "WorkSans-Medium", size: 16) ?? .systemFont(ofSize: 16)
        // Define attributes for different character types
        let alphabetAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: TokenColors.Text.primary,
            .font: customFont
        ]
        let numericAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: TokenColors.Indicator.magenta,
            .font: customFont
        ]
        let specialCharacterAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: TokenColors.Indicator.indigo,
            .font: customFont
        ]
        
        // Loop through each character and apply appropriate attributes
        for (index, character) in self.enumerated() {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(self.startIndex, offsetBy: index + 1)
            let range = NSRange(startIndex..<endIndex, in: self)
            switch character {
            case let x where x.isLetter:
                attributedString.addAttributes(alphabetAttributes, range: range)
            case let x where x.isNumber:
                attributedString.addAttributes(numericAttributes, range: range)
            case let x where x.isEmoji:
                continue
            default:
                attributedString.addAttributes(specialCharacterAttributes, range: range)
            }
        }
        
        return attributedString
    }
}
