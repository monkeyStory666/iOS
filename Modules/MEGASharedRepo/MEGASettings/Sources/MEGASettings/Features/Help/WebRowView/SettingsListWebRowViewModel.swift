// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAPresentation
import SwiftUI

public final class SettingsListWebRowViewModel: ListRowViewModel {
    public let icon: Image?
    public let title: String
    public let url: URL

    public var rowView: some View {
        SettingsListWebRowView(viewModel: self)
    }

    public init(title: String, url: URL, icon: Image? = nil) {
        self.title = title
        self.url = url
        self.icon = icon
    }
}
