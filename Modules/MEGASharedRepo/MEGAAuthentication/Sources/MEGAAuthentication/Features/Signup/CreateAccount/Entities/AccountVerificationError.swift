// Copyright © 2024 MEGA Limited. All rights reserved.

public enum AccountVerificationError: Error {
    case loggedIntoDifferentAccount
    case alreadyVerifiedOrCanceled
}
