// Copyright © 2024 MEGA Limited. All rights reserved.

import SwiftUI

extension View {
    func navigationLinkPickerStyle() -> some View {
        if #available(iOS 16, *) {
            return pickerStyle(.navigationLink)
        } else {
            return pickerStyle(.automatic)
        }
    }
}
