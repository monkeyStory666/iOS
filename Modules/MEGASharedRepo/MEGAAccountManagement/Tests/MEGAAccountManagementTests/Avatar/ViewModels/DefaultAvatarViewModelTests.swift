// Copyright © 2023 MEGA Limited. All rights reserved.

@testable import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGATest
import Testing

struct DefaultAvatarViewModelTests {
    @Test func testOnAppear_shouldLoadDefaultAvatar() async {
        let useCase = MockGenerateDefaultAvatarUseCase()
        let sut = DefaultAvatarViewModel(generateDefaultAvatarUseCase: useCase)

        await sut.onAppear()

        useCase.swt.assertActions(shouldBe: [.defaultAvatarForCurrentUser])
    }
}
