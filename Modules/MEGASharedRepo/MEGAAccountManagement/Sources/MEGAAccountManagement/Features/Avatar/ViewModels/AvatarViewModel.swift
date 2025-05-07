// Copyright © 2023 MEGA Limited. All rights reserved.

import Combine
import MEGAPresentation
import MEGAUIComponent
import UIKit

public final class AvatarViewModel: NoRouteViewModel {
    @ViewProperty var state: LoadableViewState<UIImage> = .loading

    var refreshUserDataPublisher: AnyPublisher<Void, Never> { refreshUserDataUseCase.observe() }

    private let fetchAvatarUseCase: any FetchUIImageAvatarUseCaseProtocol
    private let refreshUserDataUseCase: any RefreshUserDataNotificationUseCaseProtocol
    let defaultAvatarViewModel: DefaultAvatarViewModel

    public init(
        fetchAvatarUseCase: some FetchUIImageAvatarUseCaseProtocol = DependencyInjection.fetchUIImageAvatarUseCase,
        refreshUserDataUseCase: any RefreshUserDataNotificationUseCaseProtocol =
        DependencyInjection.refreshUserDataUseCase,
        defaultAvatarViewModel: DefaultAvatarViewModel = DefaultAvatarViewModel()
    ) {
        self.fetchAvatarUseCase = fetchAvatarUseCase
        self.refreshUserDataUseCase = refreshUserDataUseCase
        self.defaultAvatarViewModel = defaultAvatarViewModel

        super.init()

        refreshUserDataPublisher
            .sink(receiveValue: { [weak self] in
                guard let self else { return }
                Task {
                    await self.reload()
                }
            })
            .store(in: &cancellables)
    }

    public func reload() async {
        await fetchAvatar(reloadIgnoringLocalCache: true)
    }

    func load() async {
        await fetchAvatar(reloadIgnoringLocalCache: false)
    }

    /// Reloads the default avatar view only when where is no avatar (the current state is failed)
    public func reloadDefaultAvatarView() async {
        guard case .failed = state else { return }
        await defaultAvatarViewModel.reload()
    }

    private func fetchAvatar(reloadIgnoringLocalCache: Bool) async {
        if let avatar = await fetchAvatarUseCase.fetchAvatarForCurrentUser(
            reloadIgnoringLocalCache: reloadIgnoringLocalCache
        ) {
            state = .loaded(avatar)
        } else {
            state = .failed
        }
    }
}
