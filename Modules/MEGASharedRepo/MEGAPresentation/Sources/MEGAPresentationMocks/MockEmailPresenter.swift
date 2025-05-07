// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAPresentation
import MEGATest

public final class MockEmailPresenter:
    MockObject<MockEmailPresenter.Action>,
    EmailPresenting {
    public enum Action {
        case presentMailCompose
    }

    public func presentMailCompose() {
        actions.append(.presentMailCompose)
    }
}
