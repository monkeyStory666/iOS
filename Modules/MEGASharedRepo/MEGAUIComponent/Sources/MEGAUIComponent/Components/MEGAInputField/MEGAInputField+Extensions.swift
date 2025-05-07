// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public extension MEGAInputField {
    func borderColor(_ color: Color?, _ isActive: Bool = true) -> Self {
        modify(isActive) { $0.customBorderColor = color }
    }
}
