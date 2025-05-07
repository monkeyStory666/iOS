// Copyright © 2023 MEGA Limited. All rights reserved.

import UIKit

public enum Constants {
    static var isMacCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }

    public static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    public enum Link {
        static var forgotPassword = URL(string: "https://mega.nz/recovery")!
        public static var recovery = URL(string: "https://mega.nz/recovery")!
        public static var megaTermsOfService = URL(string: "https://mega.io/terms")!
        static var knowMore = URL(string: "https://mega.io/")!
    }
    
    public enum Email {
        public static var feedback = "iosfeedback@mega.nz"
        public static var support = "support@mega.nz"
    }
}
