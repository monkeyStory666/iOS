// Copyright © 2023 MEGA Limited. All rights reserved.

public struct AppLoadingEntity: Equatable {
    public var blur: Bool
    public var allowUserInteraction: Bool

    public init(
        blur: Bool = true,
        allowUserInteraction: Bool = false
    ) {
        self.blur = blur
        self.allowUserInteraction = allowUserInteraction
    }
}
