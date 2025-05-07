// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum Constants {
    public enum Link {
        static var recoveryKeyLearnMore = URL(
            string: "https://help.mega.io/accounts/password-management/recovery-key"
        )!
    }

    static var isMacCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }
}
