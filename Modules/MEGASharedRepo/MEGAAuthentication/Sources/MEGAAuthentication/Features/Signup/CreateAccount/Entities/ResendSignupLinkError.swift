// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public enum ResendSignupLinkError: Error {
    case generic
    case emailAlreadyInUse
    case emailConfirmationAlreadyRequested
}
