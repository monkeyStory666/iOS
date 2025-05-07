// Copyright © 2024 MEGA Limited. All rights reserved.

public enum Constants {
    public static var isMacCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }
}
