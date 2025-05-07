// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public struct DisplayTextWithEmail {
    public enum DisplayOption {
        case none
        case link(action: () -> Void)
        case highlight
    }

    public let text: String
    public let email: String
    public let displayOption: DisplayOption

    public init(text: String, email: String, displayOption: DisplayOption) {
        self.text = text
        self.email = email
        self.displayOption = displayOption
    }
}

extension DisplayTextWithEmail: Equatable {
    public static func == (lhs: DisplayTextWithEmail, rhs: DisplayTextWithEmail) -> Bool {
        let areDisplayOptionsEqual: Bool
        switch (lhs.displayOption, rhs.displayOption) {
        case (.none, .none), (.highlight, .highlight), (.link, .link):
            areDisplayOptionsEqual = true
        default:
            areDisplayOptionsEqual = false
        }

        return lhs.text == rhs.text && lhs.email == rhs.email && areDisplayOptionsEqual
    }
}
