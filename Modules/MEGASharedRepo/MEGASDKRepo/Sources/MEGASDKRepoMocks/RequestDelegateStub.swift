// Copyright © 2024 MEGA Limited. All rights reserved.

import MEGASdk

public typealias RequestDelegateStub = (MEGARequestDelegate, MEGASdk) -> Void

public func requestDelegateFinished(
    request: MEGARequest = MockSdkRequest(),
    error: MEGAError = MockSdkError()
) -> RequestDelegateStub {
    return { delegate, api in
        delegate.onRequestFinish?(
            api,
            request: request,
            error: error
        )
    }
}
