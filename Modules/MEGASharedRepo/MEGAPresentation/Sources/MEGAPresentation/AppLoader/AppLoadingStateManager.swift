// Copyright © 2023 MEGA Limited. All rights reserved.

import Foundation

public protocol AppLoadingStateManagerProtocol {
    func startLoading(_ entity: AppLoadingEntity)
    func stopLoading()
}

public extension AppLoadingStateManagerProtocol {
    func startLoading() {
        startLoading(AppLoadingEntity())
    }
}

public struct AppLoadingStateManager: AppLoadingStateManagerProtocol {
    private let viewModel: SecondarySceneViewModel

    public init(viewModel: SecondarySceneViewModel) {
        self.viewModel = viewModel
    }

    public func startLoading(_ entity: AppLoadingEntity) {
        viewModel.appLoading = entity
    }

    public func stopLoading() {
        viewModel.appLoading = nil
    }
}
