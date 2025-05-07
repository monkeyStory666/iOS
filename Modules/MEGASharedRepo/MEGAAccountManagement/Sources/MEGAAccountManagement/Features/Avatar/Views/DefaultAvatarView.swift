// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

struct DefaultAvatarView: View {
    @StateObject private var viewModel: DefaultAvatarViewModel

    init(viewModel: @autoclosure @escaping () -> DefaultAvatarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        Group {
            if let defaultAvatar = viewModel.defaultAvatar {
                Image(uiImage: defaultAvatar)
                    .resizable()
            } else {
                Circle()
                    .shimmering()
                    .task { await viewModel.onAppear() }
            }
        }
    }
}
