// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum SignUpErrorEntity: Error {
    case generic
    case nameEmpty
    case emailAlreadyInUse
}
