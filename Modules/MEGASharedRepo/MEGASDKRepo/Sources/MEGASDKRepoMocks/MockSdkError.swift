// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

/// Use this class to simulate error cases from the SDK in repository unit tests
public final class MockSdkError: MEGAError, @unchecked Sendable {
    let _type: MEGAErrorType

    public init(type: MEGAErrorType = .apiOk) {
        self._type = type
    }

    public override var type: MEGAErrorType {
        _type
    }
}

public extension MEGAError {
    static var apiOk: MEGAError {
        MockSdkError(type: .apiOk)
    }

    static var anyError: MEGAError {
        MockSdkError(type: .apiEAccess)
    }
}
