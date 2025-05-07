// Copyright © 2024 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGAAccountManagement
import MEGATest

public final class MockOffboardingUseCase:
    MockObject<MockOffboardingUseCase.Action>,
    OffboardingUseCaseProtocol {
    public enum Action: Equatable {
        case activeLogout(TimeInterval?)
        case forceLogout(TimeInterval?)
        case startOffBoardingPublisher
    }

    private var _startOffboardingPublisher = PassthroughSubject<Void, Never>()

    public func activeLogout(timeout: TimeInterval?) async {
        actions.append(.activeLogout(timeout))
    }

    public func forceLogout(timeout: TimeInterval?) async {
        actions.append(.forceLogout(timeout))
    }

    public func startOffboardingPublisher() -> AnyPublisher<Void, Never> {
        actions.append(.startOffBoardingPublisher)
        return _startOffboardingPublisher.eraseToAnyPublisher()
    }

    public func simulateOffboarding() {
        _startOffboardingPublisher.send()
    }
}
