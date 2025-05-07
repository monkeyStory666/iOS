// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import Foundation
import MEGADebugLogger
import MEGATest

public final class MockDebugModeUseCase:
    MockObject<MockDebugModeUseCase.Action>,
    DebugModeUseCaseProtocol {
    public enum Action: Equatable {
        case toggleDebugMode
        case observeDebugMode
    }

    public var isDebugModeEnabled: Bool
    // swiftlint:disable:next private_subject
    public var _observeDebugMode: CurrentValueSubject<Bool, Never>

    public init(
        isDebugModeEnabled: Bool = true,
        observeDebugMode: CurrentValueSubject<Bool, Never> = .init(true)
    ) {
        self.isDebugModeEnabled = isDebugModeEnabled
        self._observeDebugMode = observeDebugMode
    }

    public func toggleDebugMode() {
        actions.append(.toggleDebugMode)
    }

    public func observeDebugMode() -> AnyPublisher<Bool, Never> {
        actions.append(.observeDebugMode)
        return _observeDebugMode.eraseToAnyPublisher()
    }
}
