// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGAPreference

public protocol DebugModeUseCaseProtocol {
    var isDebugModeEnabled: Bool { get }

    func toggleDebugMode()
    func observeDebugMode() -> AnyPublisher<Bool, Never>
}

public enum PreferenceKeyEntity: String, PreferenceKeyProtocol {
    case debugMode
}

public final class DebugModeUseCase: DebugModeUseCaseProtocol {
    @PreferenceWrapper(key: PreferenceKeyEntity.debugMode, defaultValue: false)
    public private(set) var isDebugModeEnabled: Bool

    private var isDebugModeSubject: CurrentValueSubject<Bool, Never>

    public init(preferenceUseCase: some PreferenceUseCaseProtocol) {
        self.isDebugModeSubject = CurrentValueSubject(false)
        $isDebugModeEnabled.useCase = preferenceUseCase
        isDebugModeSubject.send(isDebugModeEnabled)
    }

    public func toggleDebugMode() {
        isDebugModeEnabled.toggle()
        isDebugModeSubject.send(isDebugModeEnabled)
    }

    public func observeDebugMode() -> AnyPublisher<Bool, Never> {
        isDebugModeSubject.eraseToAnyPublisher()
    }
}
