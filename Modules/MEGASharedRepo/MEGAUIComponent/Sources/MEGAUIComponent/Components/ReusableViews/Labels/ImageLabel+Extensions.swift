// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public extension ImageLabel {
    func boldText(_ isActive: Bool = true) -> Self {
        modify(isActive) { $0.boldText = true }
    }

    func boldImage(_ isActive: Bool = true) -> Self {
        modify(isActive) { $0.boldImage = true }
    }

    func hide(_ isActive: Bool = true) -> Self {
        modify(isActive) { $0.isHidden = true }
    }

    func text(_ image: Text, _ isActive: Bool = true) -> Self {
        modify(isActive) { $0.text = text }
    }

    func textColor(_ color: Color, _ isActive: Bool = true) -> Self {
        modify(isActive) { $0.textColor = color }
    }

    func icon(
        _ icon: @escaping () -> Icon,
        _ isActive: Bool = true
    ) -> ImageLabel<Icon> {
        modify(isActive) { $0.icon = icon }
    }

    func iconColor(_ color: Color, _ isActive: Bool = true) -> Self {
        modify(isActive) { $0.iconColor = color }
    }
}

struct ImageLabelExtensions_Previews: PreviewProvider {
    static var previews: some View {
        ImageLabel_Previews.previews
    }
}
