// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import Foundation
import SwiftUI

public final class SecondarySceneViewModel: NoRouteViewModel {
    @ViewProperty public var snackbarEntity: SnackbarEntity?
    @ViewProperty public var snackbarBottomPadding: CGFloat = 0
    @ViewProperty public var appLoading: AppLoadingEntity?
    @ViewProperty public var importantBottomContents: [String: CGFloat] = [:]

    public init(
        snackbarEntity: SnackbarEntity? = nil,
        appLoading: AppLoadingEntity? = nil
    ) {
        self.snackbarEntity = snackbarEntity
        self.appLoading = appLoading
        super.init()

        $importantBottomContents
            .map { $0.values.reduce(0, +) }
            .assign(to: \.snackbarBottomPadding, on: self)
            .store(in: &cancellables)
    }
}
