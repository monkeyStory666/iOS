// Copyright © 2023 MEGA Limited. All rights reserved.

import SwiftUI

public struct AvatarView: View {
    @StateObject private var viewModel: AvatarViewModel

    public init(viewModel: @autoclosure @escaping () -> AvatarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        avatar
            .clipShape(Circle())
            .task { await viewModel.load() }
    }

    @ViewBuilder var avatar: some View {
        switch viewModel.state {
        case .idle, .loading:
            Circle()
                .shimmering()
        case .failed:
            DefaultAvatarView(viewModel: viewModel.defaultAvatarViewModel)
        case .loaded(let userAvatar):
            Image(uiImage: userAvatar)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}
