// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public extension View {
    func modify(
        _ isActive: Bool = true,
        _ update: (inout Self) -> Void
    ) -> Self {
        guard isActive else { return self }

        var newSelf = self
        update(&newSelf)
        return newSelf
    }
}
