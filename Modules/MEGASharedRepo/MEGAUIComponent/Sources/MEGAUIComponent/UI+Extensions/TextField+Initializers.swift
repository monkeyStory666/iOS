// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

extension TextField where Label == EmptyView {
    init(_ binding: Binding<String>) {
        self.init(text: binding, label: { EmptyView() })
    }
}
