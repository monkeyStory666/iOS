// Copyright © 2023 MEGA Limited. All rights reserved.

import MEGAAccountManagement
import MEGAAccountManagementMocks
import MEGASdk
import MEGASDKRepo
import MEGASDKRepoMocks
import MEGASwift
import MEGATest
import Testing

struct UserAvatarRepositoryTests {
    @Test func testFetchAvatar_shouldGetBase64Handle_fromHandleEntity_andGetAvatarUserWithCorrectParams() async throws {
        let mockSdk = mockSdkWithGetAvatarRequestFinished(
            withError: .apiOk,
            andRequest: MockSdkRequest()
        )
        let base64handle = String.random()
        let destinationFilePath = String.random()
        let sut = makeSUT(sdk: mockSdk)

        _ = try? await sut.fetchAvatar(
            for: base64HandleEntity(base64: base64handle),
            destinationFilePath: destinationFilePath
        )

        #expect(mockSdk.getAvatarUserCalls.count == 1)
        #expect(
            mockSdk.getAvatarUserCalls.first?.emailOrHandle ==
            base64handle
        )
        #expect(
            mockSdk.getAvatarUserCalls.first?.destinationFilePath ==
            destinationFilePath
        )
    }

    @Test func testFetchAvatar_whenFileIsInvalid_shouldThrowInvalidFile() async {
        func assertThrowInvalidFile(
            whenFileInRequest fileInRequest: String?
        ) async {
            let mockSdk = mockSdkWithGetAvatarRequestFinished(
                withError: .apiOk,
                andRequest: MockSdkRequest(file: fileInRequest)
            )
            let sut = makeSUT(sdk: mockSdk)

            await #expect(performing: {
                _ = try await sut.fetchAvatar(
                    for: base64HandleEntity(),
                    destinationFilePath: "anyPath"
                )
            }, throws: { error in
                isError(error, equalTo: UserAvatarRepositoryError.invalidFile)
            })
        }

        await assertThrowInvalidFile(whenFileInRequest: nil)
        await assertThrowInvalidFile(
            whenFileInRequest: "fileNotContainHandle"
        )
    }

    @Test func testFetchAvatar_whenFileValid_butFailedToGetData_shouldThrowInvalidFile() async {
        let base64 = String.random(length: 12)
        let filePath = String.random(withPrefix: base64)
        let mockSdk = mockSdkWithGetAvatarRequestFinished(
            withError: .apiOk,
            andRequest: MockSdkRequest(file: filePath)
        )
        let sut = makeSUT(
            sdk: mockSdk,
            getDataFromPath: { path in
                #expect(path == filePath)
                throw ErrorInTest()
            }
        )

        await #expect(performing: {
            _ = try await sut.fetchAvatar(
                for: base64HandleEntity(base64: base64),
                destinationFilePath: "anyPath"
            )
        }, throws: { error in
            isError(error, equalTo: UserAvatarRepositoryError.dataConversionError)
        })
    }

    @Test func testFetchAvatar_whenFileValid_shouldReturnDataFromPath() async throws {
        let base64 = String.random(length: 12)
        let filePath = String.random(withPrefix: base64)
        let mockSdk = mockSdkWithGetAvatarRequestFinished(
            withError: .apiOk,
            andRequest: MockSdkRequest(file: filePath)
        )
        let expectedData = "anyData".data(using: .utf8)!
        let sut = makeSUT(
            sdk: mockSdk,
            getDataFromPath: { _ in return expectedData }
        )

        let result = try await sut.fetchAvatar(
            for: base64HandleEntity(base64: base64),
            destinationFilePath: "anyPath"
        )
        #expect(result == expectedData)
    }

    @Test func testFetchAvatar_whenRequestFailed_shouldThrowError() async throws {
        let expectedError = MockSdkError.anyError
        let mockSdk = mockSdkWithGetAvatarRequestFinished(
            withError: expectedError
        )
        let sut = makeSUT(sdk: mockSdk)

        await #expect(performing: {
            _ = try await sut.fetchAvatar(
                for: base64HandleEntity(),
                destinationFilePath: "anyPath"
            )
        }, throws: { error in
            isError(error, equalTo: expectedError)
        })
    }

    // MARK: - Test Helpers

    private func makeSUT(
        sdk: MockUserAvatarSdk = MockUserAvatarSdk(),
        getDataFromPath: @escaping GetDataFromPath = { _ in Data() }
    ) -> UserAvatarRepository<MockUserAvatarSdk> {
        UserAvatarRepository(
            sdk: sdk,
            getDataFromPath: getDataFromPath
        )
    }

    private func base64HandleEntity(
        base64: String = .random()
    ) -> Base64HandleEntity {
        base64
    }

    private func mockSdkWithGetAvatarRequestFinished(
        withError error: MEGAError,
        andRequest request: MEGARequest = MockSdkRequest()
    ) -> MockUserAvatarSdk {
        MockUserAvatarSdk(
            getAvatarUserCompletion: requestDelegateFinished(
                request: request,
                error: error
            )
        )
    }
}

private final class MockUserAvatarSdk: MEGASdk, @unchecked Sendable {
    var getAvatarUserCalls: [(
        emailOrHandle: String?,
        destinationFilePath: String
    )] = []

    var getAvatarUserCompletion: RequestDelegateStub

    init(
        getAvatarUserCompletion: @escaping RequestDelegateStub = { _, _ in }
    ) {
        self.getAvatarUserCompletion = getAvatarUserCompletion
        super.init()
    }

    override func getAvatarUser(
        withEmailOrHandle emailOrHandle: String?,
        destinationFilePath: String,
        delegate: MEGARequestDelegate
    ) {
        getAvatarUserCalls.append((emailOrHandle, destinationFilePath))
        getAvatarUserCompletion(delegate, self)
    }
}
