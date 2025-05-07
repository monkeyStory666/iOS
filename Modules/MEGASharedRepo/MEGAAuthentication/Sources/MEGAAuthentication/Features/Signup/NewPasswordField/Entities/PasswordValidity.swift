// Copyright © 2024 MEGA Limited. All rights reserved.

import Foundation

public enum PasswordValidity: Equatable, Sendable {
    case valid(password: String)
    case invalid
}
