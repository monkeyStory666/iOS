// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import MEGAAccountManagement
import MEGATest

public final class MockRefreshUserDataUseCase:
    MockObject<MockRefreshUserDataUseCase.Action>,
    RefreshUserDataNotificationUseCaseProtocol {
    public enum Action {
        case notify
        case observe
    }

    private var observer = PassthroughSubject<Void, Never>()

    public func notify() {
        actions.append(.notify)
        observer.send()
    }

    public func observe() -> AnyPublisher<Void, Never> {
        actions.append(.observe)
        return observer.eraseToAnyPublisher()
    }
}
