// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

/// This is a temporary workaround to make the SDK Sendable, which is
/// needed to make it compatible during the strict concurrency adaptation.
extension MEGASdk: @retroactive @unchecked Sendable {}
