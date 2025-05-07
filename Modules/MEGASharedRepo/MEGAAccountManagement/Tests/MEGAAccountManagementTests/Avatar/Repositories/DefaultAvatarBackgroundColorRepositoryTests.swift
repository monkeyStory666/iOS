// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGASdk
import MEGATest
import MEGASwift
import Testing

@Suite(.serialized)
struct DefaultAvatarBackgroundColorRepositoryTests {
    @Test func fetchBackgroundColor_whenUserNil_shouldThrowUserNotFound() async {
        let sut = makeSUT(sdk: MockDefaultAvatarSdk(myUser: nil))

        await #expect(performing: {
            try await sut.fetchBackgroundColor()
        }, throws: { error in
            isError(error, equalTo: DefaultAvatarBackgroundColorRepositoryError.userNotFound)
        })
    }

    @Test func fetchBackgroundColor_whenAvatarColorNil_shouldThrowColorNotFound() async {
        let sut = makeSUT(sdk: MockDefaultAvatarSdk(
            avatarColorForBase64Handle: nil
        ))

        await #expect(performing: {
            try await sut.fetchBackgroundColor()
        }, throws: { error in
            isError(error, equalTo: DefaultAvatarBackgroundColorRepositoryError.colorNotFound)
        })
    }

    @Test func fetchBackgroundColor_whenUserAndAvatarExist_shouldReturnSuccess() async throws {
        let sut = makeSUT(sdk: MockDefaultAvatarSdk(
            myUser: MEGAUser(),
            avatarColorForBase64Handle: "anyHexColor"
        ))

        let result = try await sut.fetchBackgroundColor()

        #expect(result == "anyHexColor")
    }

    @Test func fetchSecondaryBackgroundColor_whenUserNil_shouldThrowUserNotFound() async {
        let sut = makeSUT(sdk: MockDefaultAvatarSdk(myUser: nil))

        await #expect(performing: {
            try await sut.fetchSecondaryBackgroundColor()
        }, throws: { error in
            isError(error, equalTo: DefaultAvatarBackgroundColorRepositoryError.userNotFound)
        })
    }

    @Test func fetchSecondaryBackgroundColor_whenAvatarColorNil_shouldThrowColorNotFound() async {
        let sut = makeSUT(sdk: MockDefaultAvatarSdk(
            avatarSecondaryColorForBase64Handle: nil
        ))

        await #expect(performing: {
            try await sut.fetchSecondaryBackgroundColor()
        }, throws: { error in
            isError(error, equalTo: DefaultAvatarBackgroundColorRepositoryError.colorNotFound)
        })
    }

    @Test func fetchSecondaryBackgroundColor_whenUserAndAvatarExist_shouldReturnSuccess() async throws {
        let sut = makeSUT(sdk: MockDefaultAvatarSdk(
            myUser: MEGAUser(),
            avatarSecondaryColorForBase64Handle: "anyHexColor"
        ))

        let result = try await sut.fetchSecondaryBackgroundColor()

        #expect(result == "anyHexColor")
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockDefaultAvatarSdk = MockDefaultAvatarSdk()
    ) -> DefaultAvatarBackgroundColorRepository<MockDefaultAvatarSdk> {
        DefaultAvatarBackgroundColorRepository(sdk: sdk)
    }
}

private final class MockDefaultAvatarSdk: MEGASdk, @unchecked Sendable {
    static var _avatarColorForBase64Handle: String?
    static var _avatarSecondaryColorForBase64Handle: String?
    var _myUser: MEGAUser?

    init(
        myUser: MEGAUser? = MEGAUser(),
        avatarColorForBase64Handle: String? = "color",
        avatarSecondaryColorForBase64Handle: String? = "color"
    ) {
        self._myUser = myUser
        Self._avatarColorForBase64Handle = avatarColorForBase64Handle
        Self._avatarSecondaryColorForBase64Handle = avatarSecondaryColorForBase64Handle
        super.init()
    }

    override var myUser: MEGAUser? {
        _myUser
    }

    override final class func base64Handle(
        forUserHandle userhandle: UInt64
    ) -> String? {
        #expect(
            userhandle ==  MEGAUser().handle,
            "Expected to use user handle from sdk.myUser"
        )

        return "base64HandleStub"
    }

    override final class func avatarColor(
        forBase64UserHandle base64UserHandle: String?
    ) -> String? {
        #expect(base64UserHandle == "base64HandleStub")
        return _avatarColorForBase64Handle
    }

    override final class func avatarSecondaryColor(
        forBase64UserHandle base64UserHandle: String?
    ) -> String? {
        #expect(base64UserHandle == "base64HandleStub")
        return _avatarSecondaryColorForBase64Handle
    }
}
