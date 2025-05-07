// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAPresentation
import MEGATest

public final class MockAppLoadingStateManager:
    MockObject<MockAppLoadingStateManager.Action>,
    AppLoadingStateManagerProtocol {
    public enum Action: Equatable {
        case startLoading(_ entity: AppLoadingEntity)
        case stopLoading
    }

    public func startLoading(_ entity: AppLoadingEntity) {
        actions.append(.startLoading(entity))
    }

    public func stopLoading() {
        actions.append(.stopLoading)
    }
}
