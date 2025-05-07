// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGATest
import UIKit

public final class MockGenerateDefaultAvatarUseCase:
    MockObject<MockGenerateDefaultAvatarUseCase.Action>,
    GenerateDefaultAvatarUseCaseProtocol {
    public enum Action: Equatable {
        case defaultAvatarForCurrentUser
    }

    public func defaultAvatarForCurrentUser() async throws -> UIImage {
        actions.append(.defaultAvatarForCurrentUser)
        return UIImage()
    }
}
