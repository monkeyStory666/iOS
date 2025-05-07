// Copyright © 2025 MEGA Limited. All rights reserved.

import SwiftUI

public extension MEGABadge {
    init(
        infoPrimaryText: String,
        size: MEGABadgeSize = .regular,
        withIcon: Bool = true
    ) {
        self.init(
            text: infoPrimaryText,
            type: .infoPrimary,
            size: size,
            icon: withIcon ? .info : nil
        )
    }

    init(
        infoSecondaryText: String,
        size: MEGABadgeSize = .regular,
        withIcon: Bool = true
    ) {
        self.init(
            text: infoSecondaryText,
            type: .infoSecondary,
            size: size,
            icon: withIcon ? .info : nil
        )
    }

    init(
        warningText: String,
        size: MEGABadgeSize = .regular,
        withIcon: Bool = true
    ) {
        self.init(
            text: warningText,
            type: .warning,
            size: size,
            icon: withIcon ? .warning : nil
        )
    }

    init(
        errorText: String,
        size: MEGABadgeSize = .regular,
        withIcon: Bool = true
    ) {
        self.init(
            text: errorText,
            type: .error,
            size: size,
            icon: withIcon ? .error : nil
        )
    }

    init(
        successText: String,
        size: MEGABadgeSize = .regular,
        withIcon: Bool = true
    ) {
        self.init(
            text: successText,
            type: .success,
            size: size,
            icon: withIcon ? .success : nil
        )
    }
}

private extension Image {
    static var info: Image {
        Image("InfoSmallThinOutline", bundle: .module)
    }

    static var warning: Image {
        Image("AlertCircleSmallThinOutline", bundle: .module)
    }

    static var error: Image {
        Image("AlertTriangleSmallThinOutline", bundle: .module)
    }

    static var success: Image {
        Image("CheckSmallThinOutline", bundle: .module)
    }
}
