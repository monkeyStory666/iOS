// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAPresentation
import UIKit

public final class DefaultAvatarViewModel: NoRouteViewModel {
    @ViewProperty var defaultAvatar: UIImage?

    private let generateDefaultAvatarUseCase: any GenerateDefaultAvatarUseCaseProtocol

    public init(
        generateDefaultAvatarUseCase: some GenerateDefaultAvatarUseCaseProtocol =
        DependencyInjection.generateDefaultAvatarUseCase
    ) {
        self.generateDefaultAvatarUseCase = generateDefaultAvatarUseCase
    }

    func onAppear() async {
        await reload()
    }
    
    func reload() async {
        defaultAvatar = try? await generateDefaultAvatarUseCase.defaultAvatarForCurrentUser()
    }
}
